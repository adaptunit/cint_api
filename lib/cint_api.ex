defmodule CintApi do
  @moduledoc """
  Wrapper to use Cint.com REST API.
  """

  use HTTPoison.Base
  require Logger


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
    url_endpoint = config(:url) <> "panels/" <> url
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
    t = {:email_address, :gender, :member_id, :date_of_birth}
    panelist_data = Map.take(opts, Tuple.to_list(t)) |> Enum.into(%{}) |> Map.merge(%{email_address: email})
    cint_request = %{panelist: panelist_data}
    cint_request =
     case Map.has_key?(opts, :member_id) do
      true ->
       put_in(cint_request, [:panelist, :member_id], opts.member_id)
      false ->
       cint_request
     end

    country_code_iso = String.to_atom(Map.get(opts, :code_iso, "nil"))
    isCountryExist = Application.get_env(:cint_api, CintApi)[country_code_iso]

    if country_code_iso != nil and isCountryExist != nil do
      headers = headers(country_code_iso)
      client_key = Application.get_env(:cint_api, CintApi)[country_code_iso][:client_key]
      Logger.error "\nCintApi: create_panelist_by_email: |#{email}| client_key:|#{client_key}|\nHeaders: #{inspect(headers)}"

      try do
       case CintApi.post(client_key <> "/panelists", Poison.encode!(cint_request), headers, [recv_timeout: 50_000]) do
           {:ok, %{body: json_body, status_code: code, headers: response_headers}} ->
               Logger.error "\nCintApi: create_panelist_by_email: email:|#{email}| json_body:|#{json_body}| code:|#{code}|"
               case code do
                201 ->
                    {:ok, response} = Poison.decode(json_body)
                    _ ->
                    {:error, %{status_code: code, body: json_body}}
                end
            {:error, errorReason} ->
                Logger.error "\nCintApi: Error HTTPoison: client_key:| #{client_key} | errorReason:| #{inspect(errorReason)}"
       end
      rescue
       e in RuntimeError -> Logger.error "An error occurred: " <> e.message
      end
    else
     Logger.error "\nCintApi: An error occurred: create_panelist_by_email: No `code_iso` options found"
    end
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
    country_code_iso = String.to_atom(Map.get(opts, :code_iso, "nil"))
    isCountryExist = Application.get_env(:cint_api, CintApi)[country_code_iso]

    if country_code_iso != nil and isCountryExist != nil do
      headers = headers(country_code_iso)

      if Map.has_key?(opts, :cint_id) do
        panelist_id = opts.cint_id # get_in(opts, ["cint_id"])
        client_key = Application.get_env(:cint_api, CintApi)[country_code_iso][:client_key]

        patch_panelist_address = client_key <> "/panelists/" <> Kernel.inspect(panelist_id)
        try do
         {:ok, %{body: json_body, status_code: code, headers: response_headers}} = CintApi.patch(patch_panelist_address, Poison.encode!(cint_request), headers, [])
         case code
         do
          201 ->
           {:ok, response} = Poison.decode(json_body)
          _ ->
           {:error, %{status_code: code, body: %{}}}
         end
        rescue
         e in RuntimeError -> Logger.error "An error occurred: " <> e.message
        end
      else
        {:error, %{status_code: 422, body: %{}}}
      end
    else
      Logger.error "\nCintApi: An error occurred: update_panelist: No `code_iso` options found"
    end
  end


  @doc """
  Get panelists information by it's identifier.

  The following options are supported:
  """
  @spec retrieve_panelist(user_id, Keyword.t) :: {:ok, map()} | {:error, Exception.t} | no_return
  def retrieve_panelist(user_id, opts \\ []) do
    defaults = %{query_param: "email"}

    options = opts |> Enum.into(%{}) |> Map.merge(defaults)
    qp = Map.get(options, :query_param)
    case qp do
      "email" ->
          email_host = Application.get_env(:cint_api, :email)[:host]
          get_panelist("?#{qp}=#{user_id}@#{email_host}", opts)
      "member_id" ->
          get_panelist("?#{qp}=#{user_id}", opts)
      _ ->
        CintApi.error_status({:ok, %{status_code: 406}}) # Not Acceptable
    end
  end

  @spec get_panelist(query_string, Keyword.t) :: {:ok, map()} | {:error, Exception.t} | no_return
  defp get_panelist(query_string, opts \\ []) do
    country_code_iso = String.to_atom(Map.get(opts, :code_iso, "nil"))
    isCountryExist = Application.get_env(:cint_api, CintApi)[country_code_iso]

    if country_code_iso != nil and isCountryExist != nil do
      headers = headers(country_code_iso)
      client_key = Application.get_env(:cint_api, CintApi)[country_code_iso][:client_key]
      try do
       {:ok, %{body: json_body, status_code: code, headers: response_headers}} = CintApi.get(client_key <> "/panelists/#{query_string}", headers, [])
        case code
        do
         200 ->
          {:ok, response} = Poison.decode(json_body)
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
        e in RuntimeError -> Logger.error "An error occurred: " <> e.message
      end
      else
        Logger.error "\nCintApi: An error occurred: get_panelist: No `code_iso` options found"
    end
  end

  @doc """
  Create Candidate Respondent Session.

  The following options are supported:
  """
  # @spec create_candidate_respondent_session(panelist, String.t) :: {:ok, map()} | {:error, Exception.t} | no_return
  def create_candidate_respondent_session(panelist, opts)
  def create_candidate_respondent_session(panelist, opts) when is_integer(panelist) do
    create_candidate_respondent_session(to_string(panelist), opts)
  end
  def create_candidate_respondent_session(panelist, opts \\ %{}) when is_bitstring(panelist) do
    if !is_nil(panelist) do
      country_code_iso = String.to_atom(Map.get(opts, :code_iso, "nil"))
      isCountryExist = Application.get_env(:cint_api, CintApi)[country_code_iso]
      optsMap = opts |> Map.to_list
      Logger.error "\nCintApi: create_candidate_respondent_session: opts:|#{inspect(opts)}| optsMap:|#{inspect(optsMap)}|"
      # optsCint = Keyword.merge(optsMap, [:respondent_params, :quota_ids, :allow_routing, :min_cpi, :min_cr, :min_ir, :max_loi, :auto_accept_invitation]) |> Enum.map(fn {k,v}->{k,v} end) |> Map.new
      optsCint = Map.take(opts, [:respondent_params, :quota_ids, :allow_routing, :min_cpi, :min_cr, :min_ir, :max_loi, :auto_accept_invitation])
      Logger.error "\nCintApi: create_candidate_respondent_session: is_bitstring: panelist:|#{inspect(panelist)}| country_code_iso:|#{inspect(country_code_iso)}| isCountryExist:|#{inspect(isCountryExist)}| optsCint:|#{inspect(optsCint)}|"
      if country_code_iso != nil and isCountryExist != nil do
        headers = headers(country_code_iso)
        client_key = Application.get_env(:cint_api, CintApi)[country_code_iso][:client_key]

        requestEncodedJson = Poison.encode!(optsCint)
        Logger.error "\nCintApi: create_candidate_respondent_session: panelist:|#{inspect(panelist)}| opts:|#{inspect(opts)}| requestEncodedJson:|#{inspect(requestEncodedJson)}|"

        candidate_respondents_address = client_key <> "/panelists/" <> panelist <> "/candidate_respondents"
        try do
         {:ok, %{body: json_body, status_code: code, headers: response_headers}} = CintApi.post(candidate_respondents_address, requestEncodedJson, headers, [])
          case code
          do
           201 ->
            {:ok, response} = Poison.decode(json_body)
           404 ->
            {:error, %{status_code: code, error: CintApi.NotFound, message: "not found"}}
           422 ->
            {:error, %{status_code: code, error: CintApi.UnprocessableEntity, message: "unprocessable entity"}}
           _ ->
            {:error, %{status_code: code, body: %{}}}
          end
         rescue
          e in RuntimeError -> Logger.error "\n CintApi: An error occurred: " <> e.message
        end
      else
      end
    end
  end

  def create_candidate_respondent_session(panelist, opts) when is_map(panelist) do
    Logger.error "\nCintApi: create_candidate_respondent_session: is_map: panelist:|#{inspect(panelist)}| opts:|#{inspect(opts)}|"
    if Map.has_key?(panelist, :cint_id) do
      cinst_id = Map.get(panelist, :cint_id)
      cinst_id_str = Kernel.inspect(cinst_id)
      create_candidate_respondent_session(cinst_id_str)
    end
  end



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
  def access_token(country_code_iso) do
    countryKeys = Application.get_env(:cint_api, CintApi)[country_code_iso]
    Logger.error "\nCintApi: access_token: country_code_iso: |#{country_code_iso}|"

    if countryKeys == nil do
      nil
    else
      client_key = Application.get_env(:cint_api, CintApi)[country_code_iso][:client_key]
      client_secret = Application.get_env(:cint_api, CintApi)[country_code_iso][:client_secret]
      auth_token = Base.encode64("#{client_key}:#{client_secret}", padding: true) # padding: false
    end
  end


  def access_token_header_basic(country_code_iso) do
    auth_token = access_token(country_code_iso)
    if auth_token == nil do
      ""
    else
      token = "Basic #{auth_token}"
      token
    end
  end

  # Default headers added to all requests
  defp headers(country_code_iso) do
    [
      {"Content-Type", "application/json"},
      {"Accept", "application/json"},
      {"Authorization", access_token_header_basic(country_code_iso)}
    ]
  end
end
