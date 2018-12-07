# ExFirebase

A limited implementation of a Firebase Admin SDK in Elixir.

[Documentation](https://hexdocs.pm/ex_firebase/ExFirebase.html)

## Installation

Install from Hex

```elixir
def deps do
 [{:ex_firebase, "~> 0.2.0"}]
end
```

Or install from GitHub

```elixir
def deps do
  [{:ex_firebase, github: "loopsocial/ex_firebase", branch: "master"}]
end
```

Run `mix deps.get`

## Configuration

Add your Firebase Project ID and key path to your `config/config.exs` file:

```elixir
config :ex_firebase,
  project_id: "your-project-id",
  service_account_key_path: "/path/to/your/key.json"
```

## Usage

Get an OAuth2 access token for your service account

```elixir
iex> ExFirebase.Auth.get_access_token()
{:ok, "1/8xbJqaOZXSUZbHLl5EOtu1pxz3fmmetKx9W8CV4t79M"}
```

Verify a Firebase Auth ID token issued by a Firebase SDK

```elixir
iex> ExFirebase.Auth.verify_token("eyJhbGciOiJS...")
{:ok,
 %JOSE.JWT{
   fields: %{
     "aud" => "your-project-id",
     "auth_time" => 1540314428,
     "exp" => 1540318028,
     "firebase" => %{
       "identities" => %{"phone" => ["+16505553434"]},
       "sign_in_provider" => "phone"
     },
     "iat" => 1540314428,
     "iss" => "https://securetoken.google.com/your-project-id",
     "phone_number" => "+16505553434",
     "sub" => "O5dHhHaWzsgUdNo6jIeTrWykPVd2",
     "user_id" => "O5dHhHaWzsgUdNo6jIeTrWykPVd2"
   }
 }}
```

## License

MIT. See `LICENSE` file in repository.

Firebase<sup>TM</sup> is trademark of Google LLC.
