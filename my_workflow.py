from flytekit import workflow
from flytekitplugins.domino.helpers import Input, Output, run_domino_job_task
from flytekit.types.file import FlyteFile
from typing import TypeVar, NamedTuple

final_outputs = NamedTuple(
    "final_outputs",
    model_file=FlyteFile[TypeVar("rds")],
    prepared_data=FlyteFile[TypeVar("csv")]
)

@workflow
def r_ml_workflow() -> final_outputs:

    # Task 1: Data Preparation
    data_prep_results = run_domino_job_task(
        flyte_task_name="Data Preparation",
        command="Rscript /mnt/data_prep.R",
        inputs=[],
        output_specs=[Output(name="prepared_data", type=FlyteFile[TypeVar("csv")])],
        use_project_defaults_for_omitted=True
    )
    
    # Task 2: Model Training
    train_model_results = run_domino_job_task(
        flyte_task_name="Train Model",
        command="Rscript /mnt/train_model.R",
        inputs=[],
        output_specs=[Output(name="model_file", type=FlyteFile[TypeVar("rds")])],
        use_project_defaults_for_omitted=True
    )
    
    return final_outputs(
        model_file=train_model_results["model_file"],
        prepared_data=data_prep_results["prepared_data"]
    )