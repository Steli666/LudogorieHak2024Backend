defmodule HakatonBackendWeb.SessionControllerTest do
  use HakatonBackendWeb.ConnCase, async: false

  alias HakatonBackend.DB.Models.User

  describe "register/2" do
    test "successfully create a user", %{conn: conn} do
      params = %{
        first_name: "Sam",
        last_name: "Blue",
        email: "email@gmail.com",
        password: "123456",
        username: "Dobby"
      }

      assert %{"token" => _} = conn
             |> post("/api/register", params)
             |> json_response(200)
    end

    test "fail to create a user due to invalid params", %{conn: conn} do
      params = %{
        email: "email@gmail.com",
        password: "123456"
      }

      response =
        conn
        |> post("/api/register", params)
        |> json_response(400)

      assert response == %{
               "message" => "The requested action has failed.",
               "reason" => "Malformed request syntax."
             }
    end
  end

  describe "login/2" do
    test "successfully login a user", %{conn: conn} do
      params = %{
        email: "example2@gmail.com",
        password: "123456"
      }

      User.create(%{
        first_name: "Jon",
        last_name: "Doe",
        email: "example2@gmail.com",
        password: "123456",
        username: "danny22"
      })

      assert %{"token" => _token} =
               conn
               |> post("/api/login", params)
               |> json_response(200)
    end

    test "error when no account exists", %{conn: conn} do
      params = %{
        email: "email@gmail.com",
        password: "123456"
      }

      response =
        conn
        |> post("/api/login", params)
        |> json_response(401)

      assert response == %{
               "message" => "The requested action has failed.",
               "reason" => "Email or password is incorrect."
             }
    end

    test "error when wrong credentials are provided", %{conn: conn} do
      params = %{
        email: "email@gmail.com",
        password: "123456"
      }

      params
      |> Map.merge(%{username: "Microsoft", password: "invalid_password"})
      |> User.create()

      response =
        conn
        |> post("/api/login", params)
        |> json_response(401)

      assert response == %{
               "message" => "The requested action has failed.",
               "reason" => "Email or password is incorrect."
             }
    end
  end

  describe "refresh_token/2" do
    test "successfully refresh", %{conn_user: conn} do
      assert %{"token" => _token} =
        conn
        |> post("/api/refresh")
        |> json_response(200)
    end
  end
end
