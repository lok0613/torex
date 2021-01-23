defmodule TorexTest do
  use ExUnit.Case
  require Logger

  test "Torex is not using my own ip" do
    tor_ip = "https://api.myip.com"
    |> Torex.get!()
    |> Poison.decode!()
    |> Map.get("ip")

    my_ip = "https://api.myip.com"
    |> HTTPoison.get!()
    |> Map.get(:body)
    |> Poison.decode!()
    |> Map.get("ip")

    Logger.info("Tor IP - #{tor_ip}")
    Logger.info("My IP - #{my_ip}")

    assert tor_ip !== my_ip
  end
end
