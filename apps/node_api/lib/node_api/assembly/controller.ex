defmodule NodeApi.Assembly.Controller do

  alias Core.Assembly.UseCases.Creating
  alias Core.Assembly.UseCases.Getting
  alias Core.Assembly.UseCases.GettingList
  alias Core.User.UseCases.Authorization

  alias PostgresqlAdapters.User.GettingById, as: UserGettingById
  alias PostgresqlAdapters.Assembly.Inserting, as: AssemblyInserting
  alias PostgresqlAdapters.Assembly.GettingById, as: AssemblyGettingById
  alias PostgresqlAdapters.Group.GettingById, as: GroupGettingById
  alias PostgresqlAdapters.Assembly.GettingList, as: AssemblyGettingList

  defmodule AssemblyPipe do
    
    alias Core.Shared.Ports.Pipe

    @behaviour Pipe

    @impl Pipe
    def emit(%{id: id,user: user}) do
      NodeApi.AssemblyCompiler.compile(%{
        id: id,
        user: user
      })

      {:ok, true}
    end
  end

  def create(conn) do
    args = %{
      group_id: Map.get(conn.body_params, "group_id"),
      type: Map.get(conn.body_params, "type"),
      token: Map.get(conn.cookies, "access_token")
    }

    adapter_0 = UserGettingById
    adapter_1 = GroupGettingById
    adapter_2 = AssemblyInserting
    adapter_3 = AssemblyPipe

    try do
      case Creating.create(adapter_0, adapter_1, adapter_2, adapter_3, args) do
        {:ok, true} ->
          NodeApi.Logger.info("Создана сборка и отправлена на компиляцию")

          json = Jason.encode!(true)

          conn |> Plug.Conn.send_resp(200, json)

        {:error, message} -> 
          NodeApi.Handlers.handle_error(conn, message, 400)

        {:exception, message} ->
          NodeApi.Handlers.handle_exception(conn, message)
      end
    rescue
      e -> NodeApi.Handlers.handle_exception(conn, e)
    end
  end

  def update(conn, id) do
    try do
      with token <- Map.get(conn.cookies, "access_token"),
           args <- %{token: token},
           adapter_0 <- UserGettingById,
           {:ok, user} <- Authorization.auth(adapter_0, args) do

          NodeApi.AssemblyCompiler.compile(%{
            id: id,
            user: user
          })

          NodeApi.Logger.info("Сборка отправлена на компиляцию")

          json = Jason.encode!(true)

          conn |> Plug.Conn.send_resp(200, json)
        else
          {:error, message} -> 
            NodeApi.Handlers.handle_error(conn, message, 400)

          {:exception, message} -> 
            NodeApi.Handlers.handle_exception(conn, message)
        end
    rescue 
      e -> NodeApi.Handlers.handle_exception(conn, e)
    end
  end

  def list(conn) do
    filter = Map.get(conn.query_params, "filter", %{})
    sort = Map.get(conn.query_params, "sort", %{})
    pagi = Map.get(conn.query_params, "pagi", %{})

    args = %{
      token: Map.get(conn.cookies, "access_token"),
      pagi: %{
        page: NodeApi.Utils.integer_parse(pagi, "page"),
        limit: NodeApi.Utils.integer_parse(pagi, "limit"),
      },
      filter: %{
        url: Map.get(filter, "url"),
        type: Map.get(filter, "type"),
        group: Map.get(filter, "group"),
        status: NodeApi.Utils.boolen_parse(filter, "status"),
        created_f: Map.get(filter, "created_f"), 
        created_t: Map.get(filter, "created_t")
      },
      sort: %{
        type: Map.get(sort, "type"), 
        created: Map.get(sort, "created")
      }
    }

    adapter_0 = UserGettingById
    adapter_1 = AssemblyGettingList

    try do
      case GettingList.get(adapter_0, adapter_1, args) do
        {:ok, list} -> 
          NodeApi.Logger.info("Получен список сборок")

          fun = fn (assembly) -> 
            %{
              id: assembly.id,
              group: %{
                id: assembly.group.id,
                name: assembly.group.name,
                created: assembly.group.created
              },
              url: assembly.url,
              type: assembly.type,
              status: assembly.status,
              created: assembly.created
            }
          end

          json = Jason.encode!(Enum.map(list, fun))

          conn |> Plug.Conn.send_resp(200, json)

        {:error, message} -> 
          NodeApi.Handlers.handle_error(conn, message, 400)

        {:exception, message} -> 
          NodeApi.Handlers.handle_exception(conn, message)
      end
    rescue
      e -> NodeApi.Handlers.handle_exception(conn, e)
    end
  end

  def get(conn, id) do
    args = %{
      token: Map.get(conn.cookies, "access_token"),
      id: id
    }

    adapter_0 = UserGettingById
    adapter_1 = AssemblyGettingById

    try do
      case Getting.get(adapter_0, adapter_1, args) do
        {:ok, assembly} -> 
          NodeApi.Logger.info("Получена сборка")

          json = Jason.encode!(%{
            id: assembly.id,
            group: %{
              id: assembly.group.id,
              name: assembly.group.name,
              sum: assembly.group.sum,
              created: assembly.group.created
            },
            url: assembly.url,
            type: assembly.type,
            status: assembly.status,
            created: assembly.created,
            updated: assembly.updated
          })

          conn |> Plug.Conn.send_resp(200, json)

        {:error, message} -> 
          NodeApi.Handlers.handle_error(conn, message, 400)

        {:exception, message} -> 
          NodeApi.Handlers.handle_exception(conn, message)
      end
    rescue
      e-> NodeApi.Handlers.handle_exception(conn, e)
    end
  end
end