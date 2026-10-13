# config/middleware.py
import logging
logger = logging.getLogger("api.errors")

class Log400Middleware:
    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        response = self.get_response(request)
        if response.status_code == 400:
            logger.warning(
                "400 %s body=%s response=%s",
                request.path,
                request.body[:500],
                getattr(response, "content", b"")[:500],
            )
        return response