defmodule Torex do
  use Application
  alias Torex.HTTPClient
  require Logger

  @moduledoc """
  Launches hackney pool with Tor proxy
  Acccording to docs should be working, but cannot assure it is
  """
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      :hackney_pool.child_spec(:torex_pool,
        timeout: 60_000,
        recv_timeout: 60_000,
        max_connections: 1_000
      )
    ]

    opts = [strategy: :one_for_one, name: Torex.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @spec get(String.t()) :: {:ok, String.t()} | {:error, :wrong_status_code, integer(), String.t()} | {:error, Map.t()}
  def get(url) do
    request(:get, url)
  end

  @spec get!(String.t()) :: String.t()
  def get!(url) do
    case get(url) do
      {:ok, body} -> body
      whatever -> raise "Torex http get request failure - #{inspect(whatever)}"
    end
  end

  @spec post(String.t(), List.t()) :: {:ok, String.t()} | {:error, :wrong_status_code, integer(), String.t()} | {:error, Map.t()}
  def post(url, params) when is_list(params) do
    request(:post, url, Poison.encode!(params))
  end

  @spec post!(String.t(), List.t()) :: String.t()
  def post!(url, params) when is_list(params) do
    case post(url, params) do
      {:ok, body} -> body
      _ -> raise "Torex http get request failure."
    end
  end

  defp request(method, url, body \\ [], headers \\ []) when method == :get or method == :post do
    case HTTPClient.request(method, url, body, headers,
           hackney:
             [:insecure] ++
               [pool: :torex_pool, proxy: {:socks5, get_config()[:ip], get_config()[:port]}]
         ) do
      {:ok, %{status_code: 200, body: body}} ->
        {:ok, body}

      {:ok, %{status_code: status_code, body: body}} ->
        # TODO: implement this
        {:error, :wrong_status_code, status_code, body}

      {:error, %{reason: :econnrefused} = error} ->
        Logger.error("Please check Tor node is running and IP and PORT is correct in the config")
        {:error, error}

      {:error, error} ->
        {:error, error}
    end
  end

  defp get_config(), do: Application.get_env(:torex, :tor_server)

end
