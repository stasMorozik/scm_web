defmodule Core.File.Validators.Extension do
  @moduledoc """
    Валидирует расширение файла
  """

  @extensions %{
    ".jpg": true,
    ".jpeg": true,
    ".png": true,
    ".gif": true,
    ".mp4": true,
    ".avi": true
  }

  @spec valid(any()) :: Core.Shared.Types.Success.t() | Core.Shared.Types.Error.t()
  def valid(extname) when is_binary(extname) do
    case Map.get(@extensions, extname) do
      nil -> {:error, "Невалидное расширение"}
      _ -> {:ok, true}
    end
  end

  def valid(_) do
    {:error, "Невалидное расширение"}
  end
end