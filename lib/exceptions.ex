defmodule CintApi.ConfigError do
  @moduledoc """
  Raised in case there is issues with the config.
  """
  defexception [:message]
end

defmodule CintApi.ApiError do
  @moduledoc """
  Raised in case invalid response is returned from CintApi API.
  """
  defexception [:message]
end

defmodule CintApi.InvalidRequestData do
  @moduledoc """
  Raised in case request data is invalid.
  """
  defexception [:message]
end

defmodule CintApi.PolicyNotFound do
  @moduledoc """
  Raised in case no valid policy is found by the supplied criteria.
  """
  defexception [:message]
end

defmodule CintApi.UnsupportedAcceptType do
  @moduledoc """
  Raised in case request media type specified in Accept
  header is not application/json.
  """
  defexception [:message]
end

defmodule CintApi.UnsupportedMediaType do
  @moduledoc """
  Raised in case request content type specified in Content-Type
  header is not application/json.
  """
  defexception [:message]
end

defmodule CintApi.NoApplication do
  @moduledoc """
  Raised in case application doesn't exist.
  """
  defexception [:message]
end

defmodule CintApi.MethodNotAllowed do
  @moduledoc """
  Raised in case request method is not allowed.
  """
  defexception [:message]
end

defmodule CintApi.NoSecurityHeader do
  @moduledoc """
  Raised in case the clientSecret header value did not match.
  """
  defexception [:message]
end

defmodule CintApi.GenericError do
  @moduledoc """
  Raised for non-specific backend errors related to this library.
  """
  defexception [:message]
end
