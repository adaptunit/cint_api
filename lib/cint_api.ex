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

  @type policy :: String.t | integer()
  @type date :: String.t | %Date{}


  @doc """
  Append REST API main url.
  """
  @spec process_url(String.t) :: String.t
  def process_url(url) do
    config(:url) <> url
  end


  @doc """
  Get policy information by it's number.

  The following options are supported:

  * `:firstname`: check user first name
  * `:lastname`: check user last name
  * `:birthdate`: check user birth date in 09.11.1991 format
  """
  @spec policy_status(policy, Keyword.t) :: {:ok, map()} | {:error, Exception.t} | no_return
  def policy_status(number, opts \\ []) do
    policy_number = parse_policy_number(number)
    params = parse_options(opts)

    with {:ok, %{body: json_body, status_code: 200}} <-
        CintApi.get("/policystatus/#{policy_number}?#{params}", headers()),
      {:ok, response} <- Poison.decode(json_body)
    do
      {:ok, response}
    else
      {:ok, %{status_code: 400}} ->
        {:error, CintApi.InvalidRequestData}
      {:ok, %{status_code: 401}} ->
        {:error, CintApi.NoSecurityHeader}
      {:ok, %{status_code: 404}} ->
        {:error, CintApi.PolicyNotFound}
      {:ok, %{status_code: 406}} ->
        {:error, CintApi.UnsupportedAcceptType}
      {:ok, %{status_code: 409}} ->
        {:error, CintApi.NoApplication}
      {:ok, %{status_code: 500}} ->
        {:error, CintApi.ApiError}
      {:error, _} ->
        {:error, CintApi.ApiError}
      _ ->
        {:error, CintApi.GenericError}
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

  @spec parse_policy_number(policy) :: String.t
  defp parse_policy_number(number) when is_integer(number), do: to_string(number)
  defp parse_policy_number(number) when is_bitstring(number), do: number

  @spec parse_param(String.t) :: String.t
  defp parse_param(param) when is_bitstring(param) do
    String.replace(param, " ", "+")
  end

  @spec parse_birthdate(date) :: String.t
  defp parse_birthdate(%Date{} = date) do
    "#{to_string(date.day)}.#{to_string(date.month)}.#{to_string(date.year)}"
  end
  defp parse_birthdate(<< _day::bytes-size(2) >> <> "." <> << _month::bytes-size(2) >>
  <> "." <> << _year::bytes-size(4) >> = param) do
    param
  end
  defp parse_birthdate(_param) do
    raise CintApi.InvalidRequestData,
      message: "Use %Date{} struct or DD.MM.YYYY as birthdate format"
  end


  # Default headers added to all requests
  defp headers do
    [
      {"Content-Type", "application/json"},
      {"Accept", "application/json"}
    ]
  end
end
