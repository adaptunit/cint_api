defmodule CintData do
  defmodule Panelist do
    @type t :: %__MODULE__{
     email_address: String.t,
     gender: String.t,
     postal_code: String.t,
     date_of_birth: String.t,
     member_id: String.t,
     first_name: String.t,
     last_name: String.t
    }

    @enforce_keys [:email_address]
    defstruct [:email_address, :member_id, :first_name, :last_name, :gender, :postal_code, :date_of_birth, :phone_number, :street_address, :payment_method_id, :recruitment_source, :variables, :tracking_consent]
  end

end
