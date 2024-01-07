defmodule Core.Playlist.Builder do
  @moduledoc """
    Билдер сущности
  """

  @spec build(map()) :: Core.Shared.Types.Success.t() | Core.Shared.Types.Error.t()
  def build(%{name: name, contents: contents}) do
    entity() 
      |> Core.Playlist.Builders.Name.build(name)
      |> Core.Playlist.Builders.Contents.build(contents)
  end

  def build(_) do
    {:error, "Невалидные данные для построения плэйлиста"}
  end

  # Функция построения базового плэйлиста
  defp entity do
    {:ok, %Core.Playlist.Entity{
      id: UUID.uuid4(), 
      created: Date.utc_today, 
      updated: Date.utc_today
    }}
  end
end