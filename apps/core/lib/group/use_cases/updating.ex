defmodule Core.Group.UseCases.Updating do
  
  alias Core.User.UseCases.Authorization

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error
  alias Core.Shared.Types.Exception

  @spec update(
    Core.User.Ports.Getter.t(),
    Core.Group.Ports.Getter.t(),
    Core.Device.Port.GetterList.t(),
    Core.Group.Ports.Transformer.t(),
    map()
  ) :: Success.t() | Error.t() | Exception.t()
  def update(
    getter_user,
    getter_group,
    getter_list_device,
    transformer_group, 
    args
  ) when is_atom(getter_user) and
         is_atom(getter_group) and
         is_atom(getter_list_device) and
         is_atom(transformer_group) and
         is_map(args) do
    
    {result, _} = UUID.info(Map.get(args, :id))

    with :ok <- result,
         {:ok, user} <- Authorization.auth(getter_user, args),
         {:ok, group} <- getter_group.get(UUID.string_to_binary!(args.id), user),
         {:ok, pagi} <- Core.Shared.Builders.Pagi.build(Map.get(args, :pagi, %{page: 1, limit: 10})),
         {:ok, filter} <- Core.Device.Builders.Filter.build(Map.get(args, :filter, %{})),
         {:ok, sort} <- Core.Device.Builders.Sort.build(Map.get(args, :sort, %{})),
         {:ok, devices} <- getter_list_device.get(pagi, filter, sort, user),
         {:ok, group} <- Core.Group.Editor.edit(group, Map.put(args, :devices, devices)),
         {:ok, _} <- transformer_group.transform(group, user) do
      {:ok, true}
    else
      :error -> {:error, "Не валидный UUID группы"}
      {:error, message} -> {:error, message}
      {:exception, message} -> {:exception, message}
    end
  end

  def update(_, _, _, _) do
    {:error, "Невалидные данные для обновления группы"}
  end
end