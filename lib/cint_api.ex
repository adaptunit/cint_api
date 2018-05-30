defmodule CintApi do
  @moduledoc """
  Wrapper to use Cint.com REST API.
  """

  use HTTPoison.Base

  
  unless Application.get_env(:cint_api, CintApi) do
    raise CintApi.ConfigError, message: "CintApi is not configured"
  end

  unless Keyword.get(Application.get_env(:cint_api, CintApi), :url) do
    raise CintApi.ConfigError, message: "CintApi requires url"
  end

  @type user :: map()
  @type user_id :: String.t | integer()
  @type query_string :: String.t
  @type email :: String.t
  @type date :: String.t | %Date{}


  @doc """
  Append REST API main url.
  """
  @spec process_url(String.t) :: String.t
  def process_url(url) do
    url_endpoint = config(:url) <> "panels/" <> config(:client_key) <> url
    # IO.puts("url_endpoint: #{url_endpoint}")
    url_endpoint
  end

def error_status(status) do
  case status do
    {:ok, %{status_code: 400}} ->
      {:error, CintApi.BadRequest}
    {:ok, %{status_code: 401}} ->
      {:error, CintApi.NotAuthorized}
    {:ok, %{status_code: 403}} ->
      {:error, CintApi.Forbidden}
    {:ok, %{status_code: 404}} ->
      {:error, CintApi.NotFound}
    {:ok, %{status_code: 406}} ->
      {:error, CintApi.NotAcceptable}
    {:ok, %{status_code: 409}} ->
      {:error, CintApi.Conflict}
    {:ok, %{status_code: 412}} ->
      {:error, CintApi.PreconditionFailed}
    {:ok, %{status_code: 422}} ->
      {:error, CintApi.UnprocessableEntity}
    {:ok, %{status_code: 429}} ->
      {:error, CintApi.TooManyRequests}
    {:ok, %{status_code: 500}} ->
      {:error, CintApi.InternalServerError}
    {:error, _} ->
      {:error, CintApi.ApiError}
    _ ->
    {:error, CintApi.GenericError}
  end
end

  @doc """
  Get panelists information by it's identifier.

  The following options are supported:
  """
  @spec create_panelist_by_email(email, Keyword.t) :: {:ok, map()} | {:error, Exception.t} | no_return
  def create_panelist_by_email(email, opts \\ []) do
    cint_request = %{panelist: %{email_address: email}}
    headers = headers()
    try do
     {:ok, %{body: json_body, status_code: code, headers: response_headers}} = CintApi.post("/panelists", Poison.encode!(cint_request), headers, [])
     IO.puts("\n\ncreate_panelist_by_email: email:|#{email}| json_body:|#{json_body}| code:|#{code}|")
     IO.inspect(json_body)
     IO.puts("\n\nresponse_headers:|#{}|")
     IO.inspect(response_headers)
     case code
     do
      201 ->
       {:ok, response} = Poison.decode(json_body)
      _ ->
       {:error, %{status_code: code, body: %{}}}
     end
    rescue
     e in RuntimeError -> IO.puts("An error occurred: " <> e.message)
    end

    # with {:ok, %{body: json_body, status_code: 200}} <- CintApi.post("/panelists", Poison.encode!(cint_request), headers, []),
    #   {:ok, response} <- Poison.decode(json_body)
    # do
    #   {:ok, response}
    # else
    #   {error_status} ->
    #     CintApi.error_status(error_status)
    # end
  end

  @doc """
  Create CINT Panelist by given parameter with structure like %User{id: ""}
  where function will makes email address user.id <> "@email host from configuration"

  The following options are supported:
  """
  @spec create_panelist_by_user(user, Keyword.t) :: {:ok, map()} | {:error, Exception.t} | no_return
  def create_panelist_by_user(user, opts \\ []) do
    user_id = user.id
    email_host = Application.get_env(:cint_api, :email)[:host]
    create_panelist_by_email("#{user_id}@#{email_host}")
  end

  @spec create_panelist(struct()) :: {:ok, map()} | {:error, Exception.t} | no_return
  def create_panelist(struct) do
    user_email_address = struct.panelist.email_address
    create_panelist_by_email("#{user_email_address}")
  end


  @spec update_panelist(email, Keyword.t) :: {:ok, map()} | {:error, Exception.t} | no_return
  def update_panelist(panelist, opts \\ []) do
    cint_request = panelist # %{panelist: %{email_address: email}}
    IO.puts("\n\nCintApi: update_panelist: opts:")
    IO.inspect(opts)
    if Map.has_key?(opts, :cint_id) do
      panelist_id = opts.cint_id # get_in(opts, ["cint_id"])
      IO.puts("\n\nCintApi: update_panelist:")
      IO.inspect(panelist_id)
      headers = headers()
      patch_panelist_address = "/panelists/" <> Kernel.inspect(panelist_id)
      try do
       {:ok, %{body: json_body, status_code: code, headers: response_headers}} = CintApi.patch(patch_panelist_address, Poison.encode!(cint_request), headers, [])
       IO.puts("\n\nCintApi: update_panelist: json_body:|#{json_body}| code:|#{code}|")
       IO.inspect(json_body)
       IO.puts("\n\nCintApi: update_panelist: response_headers:|#{}|")
       IO.inspect(response_headers)
       case code
       do
        201 ->
         {:ok, response} = Poison.decode(json_body)
        _ ->
         {:error, %{status_code: code, body: %{}}}
       end
      rescue
       e in RuntimeError -> IO.puts("An error occurred: " <> e.message)
      end
    else
      {:error, %{status_code: 422, body: %{}}}
    end
  end


  @doc """
  Get panelists information by it's identifier.

  The following options are supported:
  """
  @spec retrieve_panelist(user_id, Keyword.t) :: {:ok, map()} | {:error, Exception.t} | no_return
  def retrieve_panelist(user_id, opts \\ []) do
    defaults = [query_param: "email"]
    options = Keyword.merge(defaults, opts) |> Enum.into(%{})
    qp = Map.get(options, :query_param)
    IO.puts("qp: #{qp}")
    # is_valid_param = if Enum.member?(["email", "member_id"], qp), do: :true, else: :false
    case qp do
      "email" ->
          email_host = Application.get_env(:cint_api, :email)[:host]
          # IO.puts("email_host: #{email_host}")
          get_panelist("?#{qp}=#{user_id}@#{email_host}")
      "member_id" ->
          get_panelist("?#{qp}=#{user_id}")
      _ ->
        CintApi.error_status({:ok, %{status_code: 406}}) # Not Acceptable
    end
  end

  @spec get_panelist(query_string) :: {:ok, map()} | {:error, Exception.t} | no_return
  defp get_panelist(query_string) do
    headers = headers()
    try do
     {:ok, %{body: json_body, status_code: code, headers: response_headers}} = CintApi.get("/panelists/#{query_string}", headers, [])
     IO.puts("json_body:|#{json_body}| code:|#{code}| response_headers:|#{}|query_string:|#{query_string}|")
     IO.inspect(response_headers)
      case code # == 200 and json_body != ""
      do
       200 ->
        {:ok, response} = Poison.decode(json_body)
        # {:ok, response}
       302 ->
        {:ok, response} = Poison.decode(json_body)
       404 ->
        # CintApi.error_status({:ok, %{status_code: code, message: "not found"}})
        {:error, %{status_code: code, error: CintApi.NotFound, message: "not found"}}
       _ ->
        {:error, %{status_code: code, body: %{}}}
        # %HTTPoison.Response{status_code: code, headers: response_headers, body: "{}"}
        # Poison.encode(%{status_code: code, body: %{}})
        # CintApi.error_status({:ok, %{status_code: code}})
      end
     rescue
      e in RuntimeError -> IO.puts("An error occurred: " <> e.message)
    end

    # with {:ok, %{body: json_body, status_code: 200}} <-
    #  CintApi.get("/panelists/#{query_string}", headers, []),
    #  IO.puts("json_body:|#{json_body}|"), # code:|#{code}|"),
    #  {:ok, response} <- Poison.decode(json_body)
    # do
    #  IO.puts("response: #{response}")
    #  {:ok, response}
    # else
    #  {error_status} ->
    #    IO.puts("error_status: #{error_status}")
    #    CintApi.error_status(error_status)
    # end
  end
  # user = if is_valid_param, do: user_id <> "@" <> Application.get_env(:client, :email)[:host], else: user_id
  # email_host = Application.get_env(:client, :email)[:host]
  # "@#{email_host}"

  @doc """
  Helper function to read global config in scope of this module.
  """
  def config, do: Application.get_env(:cint_api, CintApi)
  def config(key, default \\ nil) do
    config() |> Keyword.get(key, default) |> resolve_config(default)
  end

  defp resolve_config({:system, var_name}, default),
    do: System.get_env(var_name) || default
  defp resolve_config(value, _default),
    do: value

@doc """
  @spec parse_options(Keyword.t) :: String.t
  defp parse_options(opts) do
    params = Enum.reduce opts, %{}, fn(option, acc) ->
      case option do
        _ ->
          acc
      end
    end
    URI.encode_query(params)
  end
"""
  def access_token do
    client_key = Application.get_env(:cint_api, CintApi)[:client_key]
    client_secret = Application.get_env(:cint_api, CintApi)[:client_secret]
    auth_token = Base.encode64("#{client_key}:#{client_secret}", padding: false)
  end


  def access_token_header_basic do
    auth_token = access_token()
    token = "Basic #{auth_token}"
    token
  end

  # Default headers added to all requests
  defp headers do
    [
      {"Content-Type", "application/json"},
      {"Accept", "application/json"},
      {"Authorization", access_token_header_basic()}
    ]
  end
end
