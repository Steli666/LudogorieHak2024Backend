defmodule HakatonBackendWeb.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build common data structures and query the data layer.

  Finally, if the test case interacts with the database,
  we enable the SQL sandbox, so changes done to the database
  are reverted at the end of every test. If you are using
  PostgreSQL, you can even run database tests asynchronously
  by setting `use HakatonBackendWeb.ConnCase, async: true`, although
  this option is not recommended for other databases.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      # The default endpoint for testing
      @endpoint HakatonBackendWeb.Endpoint

      use HakatonBackendWeb, :verified_routes

      # Import conveniences for testing with connections
      import Plug.Conn
      import Phoenix.ConnTest
      import HakatonBackendWeb.ConnCase
    end
  end

  setup tags do
    HakatonBackend.DataCase.setup_sandbox(tags)
    conn = Phoenix.ConnTest.build_conn()

    {:ok, user} =
      HakatonBackend.DB.Models.User.create(%{
        first_name: "Jon",
        last_name: "Doe",
        email: "example@gmail.com",
        password: "123456",
        username: "danny2"
      })

    {:ok, token, _} = HakatonBackend.Authentication.Tokenizer.encode_and_sign(user, %{id: user.id})
    conn_user = Plug.Conn.put_req_header(conn, "authorization", "bearer: " <> token)

    {:ok, conn: Phoenix.ConnTest.build_conn(), conn_user: conn_user, user: user}
  end
end
