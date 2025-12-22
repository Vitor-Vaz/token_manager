# #!/usr/bin/env elixir

# # Script de assign token para a API de tokens
# # Uso: mix run priv/scripts/assignes_test.exs [quantidade_minima]

defmodule StressTest do
  @base_url "http://localhost:4000/api"

  def run(quantity \\ 10) do
    IO.puts("\n=== Iniciando Assign Token para todos os usuários ===")
    IO.puts("Quantidade mínima: #{quantity}")


    {:ok, _} = Application.ensure_all_started(:req)


    user_ids = get_all_users(quantity)

    IO.puts("Total de usuários: #{length(user_ids)}")
    IO.puts("================================\n")


    start_time = System.monotonic_time(:millisecond)

    tasks =
      for user_id <- user_ids do
        Task.async(fn -> assign_token(user_id) end)
      end

    results = Task.await_many(tasks, 30_000)

    end_time = System.monotonic_time(:millisecond)
    duration = end_time - start_time


    analyze_results(results, duration)
  end

  defp get_all_users(quantity) do
    IO.puts("Buscando usuários (mínimo: #{quantity})...")

    case Req.get("#{@base_url}/users/#{quantity}") do
      {:ok, %{status: 200, body: users}} when is_list(users) ->
        IO.puts("✓ #{length(users)} usuários encontrados\n")
        Enum.map(users, & &1["id"])

      {:ok, %{status: status}} ->
        IO.puts("✗ Erro ao buscar usuários (status: #{status})")
        []

      {:error, reason} ->
        IO.puts("✗ Erro ao buscar usuários: #{inspect(reason)}")
        []
    end
  end

  defp assign_token(user_id) do
    start = System.monotonic_time(:millisecond)

    IO.write(".")
    result = Req.post("#{@base_url}/assign_token/#{user_id}")

    duration = System.monotonic_time(:millisecond) - start

    case result do
      {:ok, %{status: 200, body: body}} ->
        {:success, duration, body, user_id}

      {:ok, %{status: 404, body: %{"error" => "user_not_found"}}} ->
        {:error, duration, :user_not_found, user_id}

      {:ok, %{status: status, body: body}} ->
        {:error, duration, {:http_error, status, body}, user_id}

      {:error, reason} ->
        {:error, duration, {:request_failed, reason}, user_id}
    end
  end

  defp analyze_results(results, total_duration) do
    IO.puts("\n")

    successes = Enum.count(results, &match?({:success, _, _, _}, &1))
    errors = Enum.count(results, &match?({:error, _, _, _}, &1))

    success_times =
      results
      |> Enum.filter(&match?({:success, _, _, _}, &1))
      |> Enum.map(fn {:success, time, _, _} -> time end)

    assigned_tokens =
      results
      |> Enum.filter(&match?({:success, _, _, _}, &1))
      |> Enum.map(fn {:success, _, body, _} -> body end)


    failed_users =
      results
      |> Enum.filter(&match?({:error, _, _, _}, &1))
      |> Enum.map(fn {:error, _, reason, user_id} -> {user_id, reason} end)

    unique_tokens_count =
      assigned_tokens
      |> Enum.map(& &1["token_id"])
      |> Enum.uniq()
      |> length()


    active_tokens_count = get_active_tokens_count()

    error_types =
      results
      |> Enum.filter(&match?({:error, _, _, _}, &1))
      |> Enum.map(fn {:error, _, reason, _} -> reason end)
      |> Enum.frequencies()

    IO.puts("\n=== Resultados ===")
    IO.puts("Tempo total: #{total_duration}ms")
    IO.puts("Total de requests: #{length(results)}")
    IO.puts("Sucesso: #{successes} (#{Float.round(successes / length(results) * 100, 1)}%)")
    IO.puts("Erros: #{errors} (#{Float.round(errors / length(results) * 100, 1)}%)")

    if successes > 0 do
      avg_time = Enum.sum(success_times) / length(success_times)
      min_time = Enum.min(success_times)
      max_time = Enum.max(success_times)

      IO.puts("\nTempo de resposta (sucesso):")
      IO.puts("  Média: #{Float.round(avg_time, 2)}ms")
      IO.puts("  Mínimo: #{min_time}ms")
      IO.puts("  Máximo: #{max_time}ms")
      IO.puts("  Requests/segundo: #{Float.round(successes / (total_duration / 1000), 2)}")

      IO.puts("\nTokens:")
      IO.puts("  Tokens únicos atribuídos: #{unique_tokens_count}")
      IO.puts("  Tokens ativos na API: #{active_tokens_count}")

      if unique_tokens_count == active_tokens_count do
        IO.puts("  ✓ Contagem corresponde!")
      else
        IO.puts("  ✗ Divergência detectada (diferença: #{abs(unique_tokens_count - active_tokens_count)})")

      IO.puts("\nUsuários que falharam:")
      Enum.each(failed_users, fn {user_id, reason} ->
        IO.puts("  User #{user_id}: #{inspect(reason)}")
      end)
      end
    end

    if errors > 0 do
      IO.puts("\nTipos de erro:")
      Enum.each(error_types, fn {type, count} ->
        IO.puts("  #{inspect(type)}: #{count}")
      end)
    end

    IO.puts("==================\n")
  end

  defp get_active_tokens_count do
    IO.puts("\nVerificando tokens ativos na API...")

    case Req.get("#{@base_url}/tokens?status=active") do
      {:ok, %{status: 200, body: tokens}} when is_list(tokens) ->
        length(tokens)

      _ ->
        0
    end
  end
end


args = System.argv()
quantity =
  case Enum.at(args, 0) do
    nil -> 10
    str -> String.to_integer(str)
  end

StressTest.run(quantity)
