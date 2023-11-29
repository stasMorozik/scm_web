defmodule PostgresqlAdapters.User.Inserting do
  alias Core.User.Ports.Transformer
  alias Core.User.Entity

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error
  alias Core.Shared.Types.Exception

  @behaviour Transformer

  @impl Transformer
  def transform(%Entity{} = user) do
    case :ets.lookup(:connections, "postgresql") do
      [{"postgresql", "", connection}] ->
        query = "
          INSERT INTO users (
            id, email, name, surname, created, updated
          ) VALUES(
            $1, $2, $3, $4, $5, $6
          )
        "

        with {:ok, q} <- Postgrex.prepare(connection, "", query),
             data <- [
              UUID.string_to_binary!(user.id), 
              user.email, 
              user.name, 
              user.surname, 
              user.created, 
              user.updated
             ],
             {:ok, _, _} <- Postgrex.execute(connection, q, data) do
          Success.new(true)
        else
          {:error, %Postgrex.Error{postgres: %{pg_code: "23505"}}} -> Error.new("Пользователь уже существует")
          {:error, e} -> Exception.new(e.message)
        end
      [] -> Exception.new("Database connection error")
      _ -> Exception.new("Database connection error")
    end
  end

  def transform(_) do
    Error.new("Не валидные данные для занесения пользователя в базу данных")
  end
end
