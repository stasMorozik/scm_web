defmodule Core.Playlist.UseCases.GettingList do
  @moduledoc """
    Юзекейз получения списка плэйлистов
  """

  alias Core.Playlist.Ports.GetterList

  alias Core.User.UseCases.Authorization
  alias User.Ports.Getter, as: GetterUser

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error

  alias Core.Playlist.Types.Filter
  alias Core.Playlist.Types.Sort

  alias Core.Shared.Validators.Pagination

  @spec get(
    Authorization.t(),
    GetterUser.t(),
    GetterList.t(),
    map()
  ) :: Success.t() | Error.t()
  def get(
    authorization_use_case,
    getter_user,
    getter_list,
    args
  ) when is_atom(authorization_use_case) and is_atom(getter_list) and is_map(args) do
    with true <- Kernel.function_exported?(authorization_use_case, :auth, 2),
         true <- Kernel.function_exported?(getter_list, :get, 3),
         default_filter <- %{
          name: nil, 
          created_f: nil, 
          created_t: nil, 
          updated_f: nil, 
          updated_t: nil
         },
         filter <- Map.get(args, :filter, default_filter),
         default_sort <- %{
          name: nil, 
          created: nil, 
          updated: nil
         },
         sort <- Map.get(args, :sort, default_sort),
         default_pagi <- %{
          page: 1, 
          limit: 10
         },
         pagi <- Map.get(args, :pagi, default_pagi),
         {:ok, user} <- authorization_use_case.auth(
            getter_user, %{token: Map.get(args, :token, "")}
         ),
         {:ok, pagi} <- Pagination.valid(pagi),
         filter <- %Filter{
            user_id: user.id, 
            name: Map.get(filter, :name), 
            created_f: Map.get(filter, :created_f),
            created_t: Map.get(filter, :created_t),
            updated_f: Map.get(filter, :updated_f),
            updated_t: Map.get(filter, :updated_f),
         },
         sort <- %Sort{
            name: Map.get(sort, :name), 
            created: Map.get(sort, :created), 
            updated: Map.get(sort, :updated)
         },
         {:ok, list} <- getter_list.get(filter, sort, pagi) do
      Success.new(list)
    else
      false -> Error.new("Не валидные аргументы для получения списка плэйлстов")
      {:error, message} -> {:error, message}
    end
  end

  def get(_, _, _, _) do
    Error.new("Не валидные аргументы для получения списка плэйлстов")
  end
end