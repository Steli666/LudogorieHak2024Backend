defmodule HakatonBackendWeb.Utils.Validation do
  def validate(val_function, params) do
    with :ok <- val_function.(params) do
      new_params = for {key, val} <- params, into: %{}, do: {String.to_atom(key), val}
      {:ok, new_params}
    end
  end
end
