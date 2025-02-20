defmodule Shopify.GraphQL.Response do
  alias Shopify.GraphQL.{ Config, Http }

  defstruct [:body, :headers, :status_code]

  @type t ::
          %__MODULE__{
            body: term,
            headers: Shopify.GraphQL.http_headers_t(),
            status_code: Shopify.GraphQL.http_status_code_t()
          }

  @spec new(Http.response_t(), Config.t()) :: t
  def new(response, config) do
    body =
      response
      |> Map.get(:body)
      |> maybe_json_decode(config, response)

    %__MODULE__{}
    |> Map.put(:body, body)
    |> Map.put(:headers, Map.get(response, :headers))
    |> Map.put(:status_code, Map.get(response, :status_code))
  end

  # As of 20 Feb 2025, Shopify returns html instead of json
  # on a 502 Bad Gateway response. When using Jason, this results in a
  # Jason.DecodeError error when calling config.json_codec.decode!
  defp maybe_json_decode(body, _, %{status_code: 502}), do: body

  defp maybe_json_decode(body, config, _), do: config.json_codec.decode!(body)
end
