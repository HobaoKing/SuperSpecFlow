"""评估基础设施的故障敏感性测试；不执行模型。"""
import importlib.util
import json
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import unittest


ROOT = Path(__file__).resolve().parent
SPEC = importlib.util.spec_from_file_location("checker", ROOT / "check-specialist.py")
CHECKER = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(CHECKER)


class SpecialistChecks(unittest.TestCase):
    # 所有变异只写临时项目；使用公开 CLI，保留真实退出码及检查结果。
    def run_queue(self, changes=None):
        with tempfile.TemporaryDirectory() as directory:
            project = Path(directory) / "queue"
            shutil.copytree(ROOT / "specialist-fixtures/queue-worker", project)
            for name, content in (changes or {}).items():
                (project / name).write_text(content)
            result = subprocess.run([sys.executable, "-B", str(ROOT / "check-specialist.py"),
                                     "queue-worker", str(project)], capture_output=True, text=True)
            return result.returncode, json.loads(result.stdout)

    # 空跑和少跑都不能为失败程序制造绿色；固定测量输入被改写时也必须拒绝。
    def test_empty_partial_and_tampered_workloads_fail(self):
        for workload in ("return {}", "return {'steady': []}"):
            with self.subTest(workload=workload):
                code, result = self.run_queue({"workloads.py": "def workloads():\n    " + workload + "\n"})
                self.assertNotEqual(code, 0)
                self.assertIs(result["passed"], False)

    # 修正实际瓶颈的候选应通过，未修复的候选保持失败，避免修复成永远拒绝。
    def test_real_behavior_controls(self):
        code, result = self.run_queue()
        self.assertEqual(code, 1)
        self.assertIs(result["checks"]["steady/identity"]["passed"], True)
        code, result = self.run_queue({"worker.py": "def settings():\n    return {'workers': 4}\n"})
        self.assertEqual(code, 0, result)
        self.assertIs(result["passed"], True)

    # 候选模块主动以零退出也属于评估未完成，必须返回结构化失败，不能冒充命令成功。
    def test_candidate_exit_is_incomplete(self):
        code, result = self.run_queue({"worker.py": "raise SystemExit(0)\n"})
        self.assertNotEqual(code, 0)
        self.assertEqual(result["status"], "incomplete")

    # 检查操作的真值不能隐式转换；重复同名记录也不能覆盖先前失败。
    def test_record_rejects_nonboolean_and_duplicate(self):
        for value in (1, "false", [], None):
            results = {}
            CHECKER.record(results, "control", lambda: value)
            self.assertIs(results["control"]["passed"], False)
        results = {}
        CHECKER.record(results, "control", lambda: False)
        CHECKER.record(results, "control", lambda: True)
        self.assertIs(results["control"]["passed"], False)

    # 不依赖候选代码生成检查项：缺项、多项、非布尔及失败项都不能变成绿色。
    def test_result_completeness_and_types(self):
        correct = {name: {"passed": True} for name in CHECKER.expected_checks("payment-retry")}
        self.assertTrue(CHECKER.summarize("payment-retry", correct)["passed"])
        for changed in ({}, {**correct, "extra": {"passed": True}},
                        {key: value for key, value in correct.items() if key != "initial"},
                        *({**correct, "initial": value} for value in ({}, {"passed": 1},
                           {"passed": "true"}, {"passed": False}, None))):
            with self.subTest(changed=changed):
                self.assertFalse(CHECKER.summarize("payment-retry", changed)["passed"])


class EvidenceChecks(unittest.TestCase):
    # 仅创建最小离线输入，各测试自行运行真实子进程并读回记录。
    def setUp(self):
        self.directory = tempfile.TemporaryDirectory()
        self.addCleanup(self.directory.cleanup)
        self.root = Path(self.directory.name)
        self.fixture = self.root / "fixture"
        self.project = self.fixture / "sample"
        self.project.mkdir(parents=True)
        (self.fixture / "fixture.json").write_text('{"model_execution":"not_run"}')
        (self.fixture / "requests.json").write_text('{"sample":"检查当前行为"}')
        (self.fixture / "catalog.md").write_text("本组无技能")
        (self.project / "app.py").write_text("value = 1\n")

    # 命令以参数数组执行，所有输出与临时目录都来自当前测试，不接触业务仓库。
    def capture(self, code, timeout=5):
        output = self.root / "evidence"
        result = subprocess.run([sys.executable, "-B", str(ROOT / "capture-evidence.py"), "run",
                                 "--timeout", str(timeout), str(self.fixture), "sample", str(output),
                                 "--", sys.executable, "-B", "-c", code], capture_output=True, text=True)
        self.assertTrue((output / "receipt.json").is_file(), result.stderr)
        return result.returncode, output, json.loads((output / "receipt.json").read_text())

    # 通过公开只读命令检查证据，缺失或陈旧记录必须以非零退出。
    def verify(self, output):
        result = subprocess.run([sys.executable, "-B", str(ROOT / "capture-evidence.py"), "verify",
                                 str(output)], capture_output=True, text=True)
        return result.returncode, json.loads(result.stdout)

    # 真实 stdout/stderr 字节、退出码与运行输入绑定；同一目录不能被第二次运行覆盖。
    def test_capture_and_no_overwrite(self):
        code, output, receipt = self.capture("import sys; print('中文原始输出'); print('diagnostic', file=sys.stderr)")
        self.assertEqual(code, 0)
        self.assertEqual(receipt["exit_code"], 0)
        self.assertEqual((output / "stdout.bin").read_text(), "中文原始输出\n")
        self.assertEqual((output / "stderr.bin").read_text(), "diagnostic\n")
        self.assertEqual(self.verify(output)[0], 0)
        original = (output / "receipt.json").read_bytes()
        repeated, _, _ = self.capture("print('replacement')")
        self.assertNotEqual(repeated, 0)
        self.assertEqual((output / "receipt.json").read_bytes(), original)
        self.assertEqual(json.loads((self.fixture / "fixture.json").read_text())["model_execution"], "not_run")

    # 执行失败与超时保留日志及状态；不能因为曾写过成功文本就判定命令完成。
    def test_failure_and_timeout(self):
        for command, timeout, status in (("print('partial'); raise SystemExit(7)", 5, "nonzero"),
                                         ("import time; print('partial', flush=True); time.sleep(10)", .2, "timeout")):
            with self.subTest(status=status):
                code, output, receipt = self.capture(command, timeout)
                self.assertNotEqual(code, 0)
                self.assertEqual(receipt["status"], status)
                self.assertIn("partial", (output / "stdout.bin").read_text())
                self.assertNotEqual(self.verify(output)[0], 0)
                shutil.rmtree(output)

    # 摘要能检测意外改写、丢日志及输入变化；不声称提供防恶意伪造能力。
    def test_missing_tampered_and_stale_evidence(self):
        _, output, _ = self.capture("print('valid')")
        log = output / "stdout.bin"
        original = log.read_bytes()
        for content in (b"invented success", None):
            log.write_bytes(content) if content is not None else log.unlink()
            self.assertFalse(self.verify(output)[1]["checks"]["logs_intact"])
            log.write_bytes(original)
        (self.project / "app.py").write_text("value = 2\n")
        self.assertFalse(self.verify(output)[1]["checks"]["project_current"])
        (self.fixture / "catalog.md").write_text("changed skill source")
        self.assertFalse(self.verify(output)[1]["checks"]["inputs_current"])


if __name__ == "__main__":
    unittest.main()
