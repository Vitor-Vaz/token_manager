defmodule TokenManager.TokenScheduler do
  @moduledoc """
  GenServer que executa periodicamente o job de liberação de tokens expirados.
  Roda a cada 10 segundos para garantir que tokens sejam liberados rapidamente.
  """
  use GenServer
  require Logger

  alias TokenManager.Commands.ClearExpiredTokens

  @interval :timer.seconds(10)

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @impl true
  def init(state) do
    schedule_work()
    {:ok, state}
  end

  @impl true
  def handle_info(:work, state) do
    ClearExpiredTokens.execute()
    schedule_work()
    {:noreply, state}
  end

  defp schedule_work do
    Process.send_after(self(), :work, @interval)
  end
end
