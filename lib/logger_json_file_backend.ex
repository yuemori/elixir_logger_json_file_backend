defmodule LoggerJSONFileBackend do
  use GenEvent

  @macro_env_fields Map.keys(%Macro.Env{})

  def init({__MODULE__, name}) do
    {:ok, configure(name, [])}
  end

  def handle_call({:configure, opts}, %{name: name} = state) do
    {:ok, :ok, configure(name, opts, state)}
  end

  def handle_call(:path, %{path: path} = state) do
    {:ok, {:ok, path}, state}
  end

  def handle_event({level, _gl, {Logger, msg, ts, md}}, %{level: min_level}=state) do
    if is_nil(min_level) or Logger.compare_levels(level, min_level) != :lt do
      log_event(level, msg, ts, md, state)
    else
      {:ok, state}
    end
  end

  def handle_event(:flush, state) do
    {:ok, state}
  end

  defp log_event(level, msg, ts, md, %{path: path, io_device: nil}=state) when is_binary(path) do
    case open_log(path) do
      {:ok, io_device, inode} ->
        log_event(level, msg, ts, md, %{state | io_device: io_device, inode: inode})
      _other ->
        {:ok, state}
    end
  end

  defp log_event(level, msg, ts, md, %{path: path, io_device: io_device, inode: inode, metadata: keys, json_encoder: json_encoder, triming: triming}=state) when is_binary(path) do
    if !is_nil(inode) and inode == inode(path) do
      message = json_encoder.encode!(Map.merge(%{level: level, message: (msg |> IO.iodata_to_binary), time: format_time(ts)}, take_metadata(md, keys, triming))) <> "\n"
      IO.write(io_device, message)
      {:ok, state}
    else
      File.close(io_device)
      log_event(level, msg, ts, md, %{state | io_device: nil, inode: nil})
    end
  end

  defp format_time({date, time}) do
    [Logger.Utils.format_date(date), Logger.Utils.format_time(time)]
    |> Enum.map(&IO.iodata_to_binary/1)
    |> Enum.join(" ")
  end

  defp take_metadata(metadata, _keys, false) do
    reject_keys = [:pid] ++ @macro_env_fields
    metadata |> Keyword.drop(reject_keys) |> Enum.into(%{})
  end
  defp take_metadata(metadata, keys, true) do
    List.foldr keys, %{}, fn key, acc ->
      case Keyword.fetch(metadata, key) do
        {:ok, val} -> Map.merge(acc, %{key => val})
        :error     -> acc
      end
    end
  end

  defp open_log(path) do
    case (path |> Path.dirname |> File.mkdir_p) do
      :ok ->
        case File.open(path, [:append, :utf8]) do
          {:ok, io_device} ->
            {:ok, io_device, inode(path)}
          other -> other
        end
      other -> other
    end
  end 

  defp inode(path) do
    case File.stat(path) do
      {:ok, %File.Stat{inode: inode}} -> inode
      {:error, _} -> nil
    end
  end

  defp configure(name, opts) do
    state = %{name: nil, path: nil, io_device: nil, inode: nil, level: nil, metadata: nil, json_encoder: nil, triming: false}
    configure(name, opts, state)
  end

  defp configure(name, opts, state) do
    env = Application.get_env(:logger, name, [])
    opts = Keyword.merge(env, opts)
    Application.put_env(:logger, name, opts)

    level        = Keyword.get(opts, :level, :info)
    metadata     = Keyword.get(opts, :metadata, [])
    path         = Keyword.get(opts, :path)
    json_encoder = Keyword.get(opts, :json_encoder, Poison)
    triming      = Keyword.get(opts, :metadata_triming, true)

    %{state | name: name, path: path, level: level, metadata: metadata, json_encoder: json_encoder, triming: triming}
  end
end
