defmodule Core.Assembly.Builders.Filter do
  
  alias Core.Assembly.Validators.Type
  alias Core.Assembly.Validators.Url

  alias Core.Shared.Builders.BuilderProperties

  alias Core.Shared.Validators.Date
  alias Core.Shared.Validators.Identifier
  alias Core.Shared.Validators.Boolean

  @spec build(map()) :: Core.Shared.Types.Success.t() | Core.Shared.Types.Error.t()
  def build(%{} = args) do
    setter = fn (
      entity, 
      key, 
      value
    ) -> 
      Map.put(entity, key, value) 
    end

    filter()
      |> type(Map.get(args, :type), setter)
      |> url(Map.get(args, :url), setter)
      |> group(Map.get(args, :group), setter)
      |> status(Map.get(args, :status), setter)
      |> created_f(Map.get(args, :created_f), setter)
      |> created_t(Map.get(args, :created_t), setter)
  end

  def build(_) do
    {:error, "Невалидные данные для фильтра"}
  end

  defp filter do
    {:ok, %Core.Assembly.Types.Filter{}}
  end

  defp type({:ok, filter}, type, setter) do
    case type do
      nil -> {:ok, filter}
      type -> BuilderProperties.build({:ok, filter}, Type, setter, :type, type)
    end
  end

  defp type({:error, message}, _, _) do
    {:error, message}
  end

  defp url({:ok, filter}, url, setter) do
    case url do
      nil -> {:ok, filter}
      url -> BuilderProperties.build({:ok, filter}, Url, setter, :url, url)
    end
  end

  defp url({:error, message}, _, _) do
    {:error, message}
  end

  defp group({:ok, filter}, group, setter) do
    case group do
      nil -> {:ok, filter}
      group -> BuilderProperties.build({:ok, filter}, Identifier, setter, :group, group)
    end
  end

  defp group({:error, message}, _, _) do
    {:error, message}
  end

  defp status({:ok, filter}, status, setter) do
    case status do
      nil -> {:ok, filter}
      status -> BuilderProperties.build({:ok, filter}, Boolean, setter, :status, status)
    end
  end

  defp status({:error, message}, _, _) do
    {:error, message}
  end

  defp created_f({:ok, filter}, created_f, setter) do
    case created_f do
      nil -> {:ok, filter}
      created_f -> BuilderProperties.build({:ok, filter}, Date, setter, :created_f, created_f)
    end
  end

  defp created_f({:error, message}, _, _) do
    {:error, message}
  end

  defp created_t({:ok, filter}, created_t, setter) do
    case created_t do
      nil -> {:ok, filter}
      created_t -> BuilderProperties.build({:ok, filter}, Date, setter, :created_t, created_t)
    end
  end

  defp created_t({:error, message}, _, _) do
    {:error, message}
  end
end