defmodule Group.UseCases.UpdatingTest do
  use ExUnit.Case

  alias User.FakeAdapters.Inserting, as: InsertingUser
  alias ConfirmationCode.FakeAdapters.Inserting, as: InsertingConfirmationCode

  alias ConfirmationCode.FakeAdapters.Getting, as: GettingConfirmationCode
  alias User.FakeAdapters.GettingByEmail, as: GettingUserByEmail
  alias User.FakeAdapters.GettingById, as: GettingUserById

  alias Core.Device.Builder, as: DeviceBuilder
  alias Device.FakeAdapters.Inserting, as: InsertingDevice
  alias Device.FakeAdapters.GettingList, as: GettingListDevice

  alias Group.FakeAdapters.Inserting, as: InsertingGroup
  alias Group.FakeAdapters.Getting, as: GettingGroup

  alias Core.User.UseCases.Authentication, as: AuthenticationUseCase

  alias Core.Group.Builder, as: GroupBuilder
  alias Core.Group.UseCases.Updating, as: UseCase

  setup_all do
    :mnesia.create_schema([node()])

    :ok = :mnesia.start()

    :mnesia.delete_table(:codes)
    :mnesia.delete_table(:users)
    :mnesia.delete_table(:devices)
    :mnesia.delete_table(:groups)

    {:atomic, :ok} = :mnesia.create_table(
      :codes,
      [attributes: [:needle, :created, :code, :confirmed]]
    )

    {:atomic, :ok} = :mnesia.create_table(
      :users,
      [attributes: [:id, :email, :name, :surname, :created, :updated]]
    )

    {:atomic, :ok} = :mnesia.create_table(
      :devices,
      [attributes: [:id, :ip, :latitude, :longitude, :created, :updated]]
    )

    {:atomic, :ok} = :mnesia.create_table(
      :groups,
      [attributes: [:id, :name, :sum, :devices, :created, :updated]]
    )

    :mnesia.add_table_index(:users, :email)
    :mnesia.add_table_index(:devices, :ip)

    :ok
  end

  test "Обновление группы" do
    {:ok, code} = Core.ConfirmationCode.Builder.build(
      Core.Shared.Validators.Email, "test@gmail.com"
    )

    {:ok, user} = Core.User.Builder.build(%{
      email: "test@gmail.com",
      name: "Тест",
      surname: "Тестович",
    })

    {:ok, true} = InsertingConfirmationCode.transform(code)
    {:ok, true} = InsertingUser.transform(user)
    
    {:ok, tokens}  = AuthenticationUseCase.auth(GettingConfirmationCode, GettingUserByEmail, %{
      email: "test@gmail.com",
      code: code.code
    })

    {:ok, device} = DeviceBuilder.build(%{
      ip: "192.168.1.98",
      latitude: 78.454567,
      longitude: 98.3454,
      desc: "Описание"
    })

    {:ok, group} = GroupBuilder.build(%{
      name: "Тест",
      devices: [device]
    })

    {:ok, true} = InsertingDevice.transform(device, user)

    {:ok, true} = InsertingGroup.transform(group, user)

    {result, _} = UseCase.update(GettingUserById, GettingGroup, GettingListDevice, InsertingGroup, %{
      pagi: %{
        page: 1,
        limit: 10
      },
      filter: %{
        ip: "192.168.1.98"
      },
      sort: %{},
      name: "Тест_1234",
      token: tokens.access_token,
      id: group.id
    })

    assert result == :ok
  end

  test "Обновление группы - не валидный токен" do
    {:ok, code} = Core.ConfirmationCode.Builder.build(
      Core.Shared.Validators.Email, "test@gmail.com"
    )

    {:ok, user} = Core.User.Builder.build(%{
      email: "test@gmail.com",
      name: "Тест",
      surname: "Тестович",
    })

    {:ok, true} = InsertingConfirmationCode.transform(code)
    {:ok, true} = InsertingUser.transform(user)
    
    {:ok, tokens}  = AuthenticationUseCase.auth(GettingConfirmationCode, GettingUserByEmail, %{
      email: "test@gmail.com",
      code: code.code
    })

    {:ok, device} = DeviceBuilder.build(%{
      ip: "192.168.1.98",
      latitude: 78.454567,
      longitude: 98.3454,
      desc: "Описание"
    })

    {:ok, group} = GroupBuilder.build(%{
      name: "Тест",
      devices: [device]
    })

    {:ok, true} = InsertingDevice.transform(device, user)

    {:ok, true} = InsertingGroup.transform(group, user)

    {result, _} = UseCase.update(GettingUserById, GettingGroup, GettingListDevice, InsertingGroup, %{
      pagi: %{
        page: 1,
        limit: 10
      },
      filter: %{
        ip: "192.168.1.98"
      },
      sort: %{},
      name: "Тест_1234",
      token: tokens.access_token,
      id: group.id
    })

    assert result == :ok
  end
end