import hott.init hott.hit.trunc hott.types.trunc

universes u v w
hott_theory

namespace hott
open hott.is_trunc hott.trunc

/- Properties of the product of two types -/
@[hott]
def all_prod_all {I J : Type _} (F : I -> J -> Type _) : 
  (∀ p : I × J, F p.1 p.2) -> ∀ (i : I) (j : J), F i j :=
assume all_prod i j, all_prod ⟨i,j⟩  

/- An extended elimination principle for truncations -/
@[hott]
def trunc.elim2 {n : ℕ₋₂} {A : Type _} {B : Type _} {P : Type _} [Pt : is_trunc n P] : 
  (A → B -> P) → trunc n A → trunc n B -> P :=
begin intros f tA tB, exact untrunc_of_is_trunc (trunc_functor2 f tA tB) end  

@[hott]
def sigma_Prop_eq {A : Type _} {B : Π a : A, Prop} (s₁ s₂ : Σ (a : A), B a) : 
  s₁.1 = s₂.1 -> s₁ = s₂ :=
begin 
  intro p, fapply sigma.sigma_eq, 
  exact p, apply pathover_of_tr_eq, exact is_prop.elim _ _ 
end  

/- The decode-encode technique for sums; it is contained in [types.sum] from the HoTT3 
   library, but this file does not compile. -/
@[hott, reducible, hsimp] 
def sum_code {A : Type.{u}} {B : Type.{v}} : A ⊎ B → A ⊎ B → Type (max u v) :=
  begin
    intros x y, induction x with a b; induction y with a' b',
    exact ulift.{(max u v) u} (a = a'), exact ulift empty,
    exact ulift empty, exact @ulift.{(max u v) v} (b = b')
  end   

@[hott] 
def sum_decode {A : Type.{u}} {B : Type.{v}} : 
  Π (z z' : A ⊎ B), sum_code z z' → z = z' :=
  begin
    intros z z', induction z with a b; induction z' with a' b',
    exact λ c, ap sum.inl (ulift.down c),
    exact λ c, empty.elim (ulift.down c),
    exact λ c, empty.elim (ulift.down c),
    exact λ c, ap sum.inr (ulift.down c)
  end

@[hott] 
def sum_encode {A : Type.{u}} {B : Type.{v}} {z z' : A ⊎ B} (p : z = z') : sum_code z z' :=
  by induction p; induction z; exact ulift.up idp

@[hott] 
def sum_eq_equiv {A : Type.{u}} {B : Type.{v}} {z z' : A ⊎ B} : (z = z') ≃ sum_code z z' :=
  begin
    fapply equiv.MK, apply sum_encode, apply sum_decode,
    { induction z with a b; induction z' with a' b';
       intro b; induction b with b; induction b; reflexivity },
    { intro p, induction p, induction z; refl  }
  end

end hott
