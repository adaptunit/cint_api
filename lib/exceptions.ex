defmodule CintApi.ConfigError do
  @moduledoc """
  Raised in case there is issues with the config.
  """
  defexception [:message]
end

defmodule CintApi.BadRequest do
  @moduledoc """
  Raised in case request data is invalid. You need to reformat the request and resubmit it.
  """
  defexception [:message]
end

defmodule CintApi.NotAuthorized do
  @moduledoc """
  Raised in case the clientSecret header value did not match. Authentication failed, but for whatever reason, it needs to be dealt with.
  """
  defexception [:message]
end

defmodule CintApi.Forbidden do
  @moduledoc """
  You are not authorized to access this resource.
  """
  defexception [:message]
end

defmodule CintApi.NotFound do
  @moduledoc """
  Raised in case no valid policy is found by the supplied criteria. The service is far too lazy to give us a real reason why our request failed, but
whatever the reason, it needs to be dealt with.
  """
  defexception [:message]
end

defmodule CintApi.MethodNotAllowed do
  @moduledoc """
  Raised in case request method is not allowed.
  """
  defexception [:message]
end

defmodule CintApi.NotAcceptable do
  @moduledoc """
  Raised in case request media type specified in Accept
  header is not application/json.
  """
  defexception [:message]
end

defmodule CintApi.Conflict do
  @moduledoc """
  You tried to update the state of a resource, but the service isn't happy about it. We'll need to get the current state of the resource (either by checking the response entity body, or doing a GET) and figure out where to go from there.
  """
  defexception [:message]
end

defmodule CintApi.PreconditionFailed do
  @moduledoc """
  The request wasn’t processed because an Etag, If-Match or similar guard header failed evaluation.
  """
  defexception [:message]
end

defmodule CintApi.UnprocessableEntity do
  @moduledoc """
  The request wasn't processed because the data failed validation. See the XML schema ‘errors.rng’ for more details and the errors entity for an example.
  """
  defexception [:message]
end

defmodule CintApi.TooManyRequests do
  @moduledoc """
  The request wasn’t processed, too many requests have been sent within a given time period, a retry-after header is sent with the appropriate time in which the request can be resent to be processed.
  """
  defexception [:message]
end

defmodule CintApi.InternalServerError do
  @moduledoc """
  The ultimate lazy response. The server's gone wrong and it's not telling why.
  """
  defexception [:message]
end

defmodule CintApi.GenericError do
  @moduledoc """
  Raised for non-specific backend errors related to this library.
  """
  defexception [:message]
end

defmodule CintApi.ApiError do
  @moduledoc """
  Raised in case invalid response is returned from CintApi API.
  """
  defexception [:message]
end
