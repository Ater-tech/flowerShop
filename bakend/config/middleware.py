# import sys

# class Log400Middleware:
#     def __init__(self, get_response):
#         self.get_response = get_response
#         print("Log400Middleware v2 loaded", file=sys.stderr, flush=True)

#     def __call__(self, request):
#         try:
#             body = request.body  # view'dan OLDIN o'qiladi
#         except Exception:
#             body = b""

#         response = self.get_response(request)

#         if response.status_code >= 400 and request.path.startswith("/api/orders/"):
#             content = getattr(response, "content", b"")
#             print(
#                 f"[API {response.status_code}] {request.method} {request.path}\n"
#                 f"  REQUEST:  {body[:1000]!r}\n"
#                 f"  RESPONSE: {content[:1000]!r}",
#                 file=sys.stderr,
#                 flush=True,
#             )
#         return response
    
# # import logging
# # logger = logging.getLogger("api.errors")

# # class Log400Middleware:
# #     def __init__(self, get_response):
# #         self.get_response = get_response

# #     def __call__(self, request):
# #         response = self.get_response(request)
# #         if response.status_code == 400:
# #             logger.warning(
# #                 "400 %s body=%s response=%s",
# #                 request.path,
# #                 request.body[:500],
# #                 getattr(response, "content", b"")[:500],
# #             )
# #         return response