defmodule CandidateRespondent do
    use Ecto.Schema
    import Ecto.Changeset
    import Ecto.Query

    # defstruct [:respondent_params, :quota_ids, :allow_routing, :min_cpi, :min_cr, :min_ir, :max_loi, :auto_accept_invitation]
    @optional_fields ~w(respondent_params quota_ids allow_routing min_cpi min_cr min_ir max_loi auto_accept_invitation)

    schema "candidate_respondent" do
        field :respondent_params, :string
        field :quota_ids, :map
        field :allow_routing, :boolean
        field :min_cpi, :float
        field :min_cr, :integer
        field :min_ir, :integer
        field :max_loi, :integer
        field :auto_accept_invitation, :boolean
    end

    def changeset(struct, params \\ %{}) do
        struct
        |> cast(params, @optional_fields)
    end
end
