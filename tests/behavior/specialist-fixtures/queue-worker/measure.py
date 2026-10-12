import json
from worker import settings
from workloads import workloads
from simulator import run

if __name__ == "__main__":
    print(json.dumps({name: run(jobs, settings())["metrics"] for name, jobs in workloads().items()}, indent=2))
