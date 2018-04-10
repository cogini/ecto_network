defmodule EctoNetwork.INET do
  @moduledoc ~S"""
  Support for using Ecto with :inet fields
  """

  @behaviour Ecto.Type

  def type, do: :inet

  @doc "Handle casting to Postgrex.INET"
  def cast(%Postgrex.INET{}=address), do: {:ok, address}
  def cast(address) when is_tuple(address), do: {:ok, %Postgrex.INET{address: address}}
  def cast(address) when is_binary(address) do
    case String.split(address, "/") do
      [address] ->
        cast_result(parse_address(address), nil)
      [address, netmask] ->
        cast_result(parse_address(address), parse_netmask(netmask))
    end
  end
  def cast(_), do: :error

  @doc "Load from the native Ecto representation"
  def load(%Postgrex.INET{}=address), do: {:ok, address}
  def load(_), do: :error

  @doc "Convert to the native Ecto representation"
  def dump(%Postgrex.INET{}=address), do: {:ok, address}
  def dump(_), do: :error

  @doc "Convert from native Ecto representation to a binary"
  def decode(%Postgrex.INET{address: address, netmask: nil}) do
    case :inet.ntoa(address) do
      {:error, _einval} -> :error
      formated_address  -> List.to_string(formated_address)
    end
  end
  def decode(%Postgrex.INET{address: address, netmask: netmask}) do
    case :inet.ntoa(address) do
      {:error, _einval} -> :error
      formatted_address -> List.to_string(formatted_address) <> "/#{netmask}"
    end
  end

  @spec parse_address(binary) :: {:ok, :inet.ip_address} | {:error, :einval}
  defp parse_address(address) do
    address
    |> String.to_charlist()
    |> :inet.parse_address()
  end

  @spec parse_netmask(binary) :: integer | :error
  defp parse_netmask(netmask) do
    case Integer.parse(netmask) do
      {value, _rest} -> value
      :error -> :error
    end
  end

  defp cast_result({:ok, _address}, :error), do: :error
  defp cast_result({:ok, address}, netmask) do
    {:ok, %Postgrex.INET{address: address, netmask: netmask}}
  end
  defp cast_result(_, _), do: :error

end

defimpl String.Chars, for: Postgrex.INET do
  def to_string(%Postgrex.INET{}=address), do: EctoNetwork.INET.decode(address)
end

if Code.ensure_loaded?(Phoenix.HTML) do
  defimpl Phoenix.HTML.Safe, for: Postgrex.INET do
    def to_iodata(%Postgrex.INET{}=address), do: EctoNetwork.INET.decode(address)
  end
end
