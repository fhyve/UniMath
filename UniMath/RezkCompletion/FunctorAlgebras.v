(** **********************************************************

Benedikt Ahrens
started March 2015


************************************************************)


(** **********************************************************

Contents :  

        - precategory of algebras of an endofunctor
        - saturated if base precategory is
		           
************************************************************)


Require Import Foundations.Generalities.uu0.
Require Import Foundations.hlevel1.hProp.
Require Import Foundations.hlevel2.hSet.

Require Import RezkCompletion.precategories.
Require Import RezkCompletion.functors_transformations.
Require Import RezkCompletion.UnicodeNotations.
Require Import RezkCompletion.whiskering.

Local Notation "# F" := (functor_on_morphisms F)(at level 3).
Local Notation "F ⟶ G" := (nat_trans F G) (at level 39).
Local Notation "G □ F" := (functor_composite _ _ _ F G) (at level 35).

Ltac pathvia b := (apply (@pathscomp0 _ _ b _ )).


Section Algebra_Definition.

Variable C : precategory.
Variable F : functor C C.

Definition algebra_ob : UU := Σ X : C, F X ⇒ X.

Coercion ob_from_algebra_ob (X : algebra_ob) : C := pr1 X.

Definition alg_map (X : algebra_ob) : F X ⇒ X := pr2 X.

Definition algebra_mor (X Y : algebra_ob) : UU :=
  Σ f : X ⇒ Y, alg_map X ;; f = #F f ;; alg_map Y.

Coercion mor_from_algebra_mor (X Y : algebra_ob) (f : algebra_mor X Y) : X ⇒ Y := pr1 f.

Definition isaset_algebra_mor (hs : has_homsets C) (X Y : algebra_ob) : isaset (algebra_mor X Y).
Proof.
  apply (isofhleveltotal2 2).
  - apply hs.
  - intro f.
    apply isasetaprop.
    apply hs.
Qed.

Definition algebra_mor_eq (hs : has_homsets C) {X Y : algebra_ob} {f g : algebra_mor X Y}
  : (f : X ⇒ Y) = g ≃ f = g.
Proof.
  apply invweq.
  apply (total2_paths_isaprop_equiv).
  intro a. apply hs.
Defined.

Lemma algebra_mor_commutes (X Y : algebra_ob) (f : algebra_mor X Y) 
  : alg_map X ;; f = #F f ;; alg_map Y.
Proof.
  exact (pr2 f).
Qed.

Definition algebra_mor_id (X : algebra_ob) : algebra_mor X X.
Proof.
  exists (identity _ ).
  pathvia (alg_map X).
  - apply id_right.
  - apply pathsinv0.
    pathvia (identity _ ;; alg_map X).
    + rewrite functor_id. apply idpath.
    + apply id_left.
Defined.

Definition algebra_mor_comp (X Y Z : algebra_ob) (f : algebra_mor X Y) (g : algebra_mor Y Z)
  : algebra_mor X Z.
Proof.
  exists (f ;; g).
  rewrite assoc.
  rewrite algebra_mor_commutes.
  rewrite <- assoc.
  rewrite algebra_mor_commutes.
  rewrite functor_comp, assoc.
  apply idpath.
Defined.  

Definition precategory_alg_ob_mor : precategory_ob_mor.
Proof.
  exists algebra_ob.
  exact algebra_mor.
Defined.

Definition precategory_alg_data : precategory_data.
Proof.
  exists precategory_alg_ob_mor.
  exists algebra_mor_id.
  exact algebra_mor_comp.
Defined.

Lemma is_precategory_precategory_alg_data (hs : has_homsets C) 
  : is_precategory precategory_alg_data.
Proof.
  repeat split; intros; simpl.
  - apply algebra_mor_eq.
    + apply hs.
    + apply id_left.
  - apply algebra_mor_eq.
    + apply hs.
    + apply id_right.
  - apply algebra_mor_eq.
    + apply hs.
    + apply assoc.
Qed.

Definition precategory_FunctorAlg (hs : has_homsets C) 
  : precategory := tpair _ _ (is_precategory_precategory_alg_data hs).

Lemma has_homsets_FunctorAlg (hs : has_homsets C) 
  : has_homsets (precategory_FunctorAlg hs).
Proof.
  intros f g.  
  apply isaset_algebra_mor.
  assumption.
Qed.

Section FunctorAlg_saturated.

Hypothesis H : is_category C.

Definition algebra_eq_type (X Y : precategory_FunctorAlg (pr2 H)) : UU 
  := Σ p : iso (pr1 X) (pr1 Y), pr2 X ;; p = #F p ;; pr2 Y.

Definition algebra_ob_eq (X Y : precategory_FunctorAlg (pr2 H)) : 
  (X = Y) ≃ algebra_eq_type X Y.
Proof.
  eapply weqcomp.
  - apply total2_paths_equiv.
  - set (H1 := weqpair _ (pr1 H (pr1 X) (pr1 Y))).
    apply (weqbandf H1).
    simpl.
    intro p.
    destruct X as [X α].
    destruct Y as [Y β]; simpl in *.
    destruct p.  
    apply weqimplimpl.
    + intro x; simpl.
      rewrite functor_id.
      rewrite id_left, id_right.
      apply x.
    + simpl; rewrite functor_id, id_left, id_right.
      induction 1. apply idpath.
    + apply (pr2 H).
    + apply (pr2 H).
Defined.

Definition is_iso_from_is_algebra_iso (X Y : precategory_FunctorAlg (pr2 H)) (f : X ⇒ Y)
  : is_iso f → is_iso (pr1 f).
Proof.
  intro p.
  apply is_iso_from_is_z_iso.
  set (H' := iso_inv_after_iso (isopair f p)).
  set (H'':= iso_after_iso_inv (isopair f p)).
  exists (pr1 (inv_from_iso (isopair f p))).
  split; simpl. 
  - apply (maponpaths pr1 H').
  - apply (maponpaths pr1 H'').
Defined.

Definition inv_algebra_mor_from_is_iso {X Y : precategory_FunctorAlg (pr2 H)} (f : X ⇒ Y) 
  : is_iso (pr1 f) → (Y ⇒ X).
Proof.
  intro T.
  set (fiso:=isopair (pr1 f) T).
  set (finv:=inv_from_iso fiso).
  exists finv.
  unfold finv.
  apply pathsinv0.
  apply iso_inv_on_left.
  simpl.
  rewrite functor_on_inv_from_iso.
  rewrite <- assoc.
  apply pathsinv0.
  apply iso_inv_on_right.
  simpl.
  apply (pr2 f).
Defined.

Definition is_algebra_iso_from_is_iso {X Y : precategory_FunctorAlg (pr2 H)} (f : X ⇒ Y) 
  : is_iso (pr1 f) → is_iso f.
Proof.
  intro T.
  apply is_iso_from_is_z_iso.
  exists (inv_algebra_mor_from_is_iso f T).
  split; simpl.
  - apply algebra_mor_eq.
    + apply (pr2 H).
    + simpl.
      apply (iso_inv_after_iso (isopair (pr1 f) T)).
  - apply algebra_mor_eq.
    + apply (pr2 H).
    + apply (iso_after_iso_inv (isopair (pr1 f) T)).
Defined.

Definition algebra_iso_first_iso {X Y : precategory_FunctorAlg (pr2 H)}
  : iso X Y ≃ Σ f : X ⇒ Y, is_iso (pr1 f).
Proof.
  apply (weqbandf (idweq _ )).
  intro f.
  apply weqimplimpl; simpl.
  - apply is_iso_from_is_algebra_iso.
  - apply is_algebra_iso_from_is_iso.
  - apply isaprop_is_iso.
  - apply isaprop_is_iso.
Defined.

Definition swap (A B : UU) : A × B → B × A.
Proof.
  intro ab.
  exists (pr2 ab).
  exact (pr1 ab).
Defined.  

Definition swapweq (A B : UU) : (A × B) ≃ (B × A).
Proof.
  exists (swap A B).
  apply (gradth _ (swap B A)).
  - intro ab. destruct ab. apply idpath. 
  - intro ba. destruct ba. apply idpath.
Defined.

Definition algebra_iso_rearrange {X Y : precategory_FunctorAlg (pr2 H)}
  : (Σ f : X ⇒ Y, is_iso (pr1 f)) ≃ algebra_eq_type X Y.
Proof.
  eapply weqcomp.
  - apply weqtotal2asstor.
  - simpl. unfold algebra_eq_type.
    apply invweq.
    eapply weqcomp.
    + apply weqtotal2asstor.
    + apply (weqbandf (idweq _ )).
      intro f; simpl.
      apply swapweq.
Defined.

Definition algebra_idtoiso (X Y : precategory_FunctorAlg (pr2 H)) : 
  (X = Y) ≃ iso X Y.
Proof.
  eapply weqcomp.
  - apply algebra_ob_eq.
  - eapply weqcomp.
    + apply (invweq (algebra_iso_rearrange)).
    + apply (invweq algebra_iso_first_iso).
Defined.

Lemma isweq_idtoiso_FunctorAlg (X Y : precategory_FunctorAlg (pr2 H))
  : isweq (@idtoiso _ X Y).
Proof.
  apply (isweqhomot (algebra_idtoiso X Y)).
  - intro p. induction p.
    simpl. apply eq_iso. apply algebra_mor_eq.
    + apply (pr2 H).
    + apply idpath.
  - apply (pr2 _ ).
Defined.
     

End FunctorAlg_saturated.

End Algebra_Definition.