defmodule HakatonBackend.DB.Model do
  @moduledoc false

  defmacro __using__(opts) do
    default_preloads = Keyword.get(opts, :default_preloads, [])

    quote do
      use Ecto.Schema
      import Ecto.Changeset
      import Ecto.Query, warn: false
      alias HakatonBackend.Repo

      def get(id, preloads \\ unquote(default_preloads)) do
        case Repo.get(__MODULE__, id) |> Repo.preload(preloads) do
          entry when not is_nil(entry) -> {:ok, entry}
          _ -> {:error, :not_found, __MODULE__}
        end
      end

      def create(attrs, preloads \\ unquote(default_preloads)) do
        struct(__MODULE__, %{})
        |> changeset(attrs)
        |> Repo.insert()
        |> case do
          {:ok, entry} ->
            {:ok, Repo.preload(entry, preloads)}

          {:error, error} ->
            {:error, error}
        end
      end

      def get_by(fields, preloads \\ unquote(default_preloads)) do
        where_clause = where_clause(fields)

        query =
          from(u in __MODULE__,
            where: ^where_clause,
            select: u
          )

        case Repo.one(query) |> Repo.preload(preloads) do
          entry when not is_nil(entry) -> {:ok, entry}
          _ -> {:error, :not_found, __MODULE__}
        end
      end

      def where_clause(search_terms) do
        where_match_clause = fn {k, v}, conditions ->
          dynamic([q], field(q, ^k) == ^v and ^conditions)
        end

        Enum.reduce(search_terms, true, &where_match_clause.(&1, &2))
      end

      def all(preloads \\ unquote(default_preloads)) do
        {:ok,
         Repo.all(__MODULE__)
         |> Repo.preload(preloads)}
      end

      def update(id, attrs, preloads \\ unquote(default_preloads)) do
        case Repo.get(__MODULE__, id) do
          nil ->
            {:error, :not_found, __MODULE__}

          entry ->
            changeset = changeset(entry, attrs)

            case Repo.update(changeset) do
              {:ok, entry} -> {:ok, entry |> Repo.preload(preloads)}
              {:error, changeset} -> {:error, changeset}
            end
        end
      end

      def delete(id) do
        case Repo.get(__MODULE__, id) do
          nil -> {:error, :not_found, __MODULE__}
          entry -> Repo.delete(entry)
        end
      end

      defoverridable(
        create: 1,
        create: 2,
        update: 3,
        delete: 1
      )
    end
  end
end
