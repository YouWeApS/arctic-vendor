# Errors

> Example error response

```json
{
  "error": "Unauthorized",
  "description": "Invalid or missing Bearer token Authentication header"
}
```

The Arctic Core API uses the [HTTP status codes](httpstatuses.com) list. Here is some additional explenations for some of the HTTP status codes.

Error Code | Meaning
---------- | -------
401 | Unauthorized -- Your Vendor token is incorrect or missing.
403 | Forbidden -- Your Vendor token doesn't have the proper permissions for the action.
