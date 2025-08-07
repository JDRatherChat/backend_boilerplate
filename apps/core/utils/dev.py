import time
from functools import wraps

from django.conf import settings
from django.db import connection, reset_queries


def query_debugger(func):
    @wraps(func)
    def wrapper(*args, **kwargs):
        if not settings.DEBUG:
            return func(*args, **kwargs)

        reset_queries()
        start_time = time.time()
        result = func(*args, **kwargs)
        end_time = time.time()

        execution_time = end_time - start_time
        print(f"Function: {func.__name__}")
        print(f"Number of Queries: {len(connection.queries)}")
        print(f"Execution time: {execution_time:.3f}s")

        return result

    return wrapper
