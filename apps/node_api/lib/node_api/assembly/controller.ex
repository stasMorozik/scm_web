defmodule NodeApi.Assembly.Controller do

  alias Core.Assembly.UseCases.Creating
  alias Core.Assembly.UseCases.Getting
  alias Core.Assembly.UseCases.GettingList

  alias PostgresqlAdapters.User.GettingById, as: UserGettingById
  alias PostgresqlAdapters.Assembly.Inserting, as: AssemblyInserting
  alias PostgresqlAdapters.Assembly.GettingById, as: AssemblyGettingById
  alias PostgresqlAdapters.Group.GettingById, as: GroupGettingById
  alias PostgresqlAdapters.Assembly.GettingList, as: AssemblyGettingList

  @name_node Application.compile_env(:node_api, :name_node)

  defmodule AssemblyPipe do
    
    alias Core.Shared.Ports.Pipe

    @behaviour Pipe

    @impl Pipe
    def emit(%{
      id: id,
      user: user
    }) do
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

    try do
      case Creating.create(
        UserGettingById, 
        GroupGettingById, 
        AssemblyInserting, 
        AssemblyPipe, 
        args
      ) do
        {:ok, true} ->
          ModLogger.Logger.info(%{
            message: "Создана сборка и отправлена на компиляцию", 
            node: @name_node
          })

          conn |> Plug.Conn.send_resp(200, Jason.encode!(true))

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

    try do
      case GettingList.get(UserGettingById, AssemblyGettingList, args) do
        {:ok, list} -> 
          ModLogger.Logger.info(%{
            message: "Получен список сборок", 
            node: @name_node
          })

          conn |> Plug.Conn.send_resp(200, Jason.encode!(
            Enum.map(list, fn (assembly) -> 
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
            end)
          ))

        {:error, message} -> NodeApi.Handlers.handle_error(conn, message, 400)

        {:exception, message} -> NodeApi.Handlers.handle_exception(conn, message)
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

    try do
      case Getting.get(UserGettingById, AssemblyGettingById, args) do
        {:ok, assembly} -> 
          ModLogger.Logger.info(%{
            message: "Получена группа устройств", 
            node: @name_node
          })

          conn |> Plug.Conn.send_resp(200, Jason.encode!(%{
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
          }))

        {:error, message} -> NodeApi.Handlers.handle_error(conn, message, 400)

        {:exception, message} -> NodeApi.Handlers.handle_exception(conn, message)
      end
    rescue
      e -> NodeApi.Handlers.handle_exception(conn, e)
    end
  end
end