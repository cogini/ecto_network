defmodule EctoNetwork.CIDR do
  @moduledoc ~S"""
  Support for using Ecto with :cidr fields
  """

  @behaviour Ecto.Type

  def type, do: :cidr

  @doc "Handle casting to Postgrex.INET"
  def cast(%Postgrex.INET{}=address), do: {:ok, address}
  def cast(address) when is_binary(address) do
    [address, netmask] = String.split(address, "/")

    {:ok, parsed_address} =
      address
      |> String.to_charlist()
      |> :inet.parse_address

    netmask = String.to_integer(netmask)

    {:ok, %Postgrex.INET{address: parsed_address, netmask: netmask}}
  end
  def cast(_), do: :error

  @doc "Load from the native Ecto representation"
  def load(%Postgrex.INET{}=address), do: {:ok, address}
  def load(_), do: :error

  @doc "Convert to the native Ecto representation"
  def dump(%Postgrex.INET{}=address), do: {:ok, address}
  def dump(_), do: :error

end
