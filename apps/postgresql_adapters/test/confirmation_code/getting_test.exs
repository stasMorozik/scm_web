defmodule ConfirmationCode.GettingTest do
  use ExUnit.Case

  alias PostgresqlAdapters.ConfirmationCode.Inserting
  alias PostgresqlAdapters.ConfirmationCode.Getting
  alias Core.ConfirmationCode.Builder
  alias Core.Shared.Validators.Email

  doctest PostgresqlAdapters.ConfirmationCode.Getting

  setup_all do
    :ets.new(:connections, [:set, :public, :named_table])

    {:ok, pid} = Postgrex.start_link(
      hostname: Application.fetch_env!(:postgresql_adapters, :hostname),
      username: Application.fetch_env!(:postgresql_adapters, :username),
      password: Application.fetch_env!(:postgresql_adapters, :password),
      database: Application.fetch_env!(:postgresql_adapters, :database),
      port: Application.fetch_env!(:postgresql_adapters, :port)
    )

    :ets.insert(:connections, {"postgresql", "", pid})

    # Postgrex.query!(pid, "DELETE FROM confirmation_codes WHERE needle != 'stanim857@gmail.com'", [])

    :ok
  end

  # test "Get" do
  #   {:ok, code_entity} = Builder.build("test@gmail.com", Email)

  #   Inserting.transform(code_entity)

  #   {result, _} = Getting.get("test@gmail.com")

  #   assert result == :ok
  # end

  # test "Code not found" do
  #   {result, _} = Getting.get("test111@gmail.com")

  #   assert result == :error
  # end
end
