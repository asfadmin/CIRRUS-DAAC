import logging

from run_cumulus_task import run_cumulus_task

logger = logging.getLogger()
logger.setLevel(logging.INFO)


def _nop():
    """
    Implements the No Operation function. It does nothing!
    """
    logger.info("NOP called. Doing nothing!")


def _cma_output(result):
    """
    Returns a dict with the NOP result.
    """
    return {"NOP": result}


def process_event(event, context):
    """Processes the Cumulus event and creates a Cumulus-compatible
    output.
    """
    result = _nop()

    return _cma_output(result)


def lambda_handler(event, context):
    """AWS Lambda Function entrypoint

    Parameters
    ----------
    event: dict, required
        Lambda trigger event
    context: object, required
        Lambda Context runtime methods and attributes
        Context doc:
          https://docs.aws.amazon.com/lambda/latest/dg/python-context-object.html
    """
    return run_cumulus_task(process_event, event, context)
