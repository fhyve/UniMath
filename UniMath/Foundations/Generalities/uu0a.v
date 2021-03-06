(** * Univalent Basics. 

Vladimir Voevodsky. 
Feb. 2010 - Sep. 2011.


The first part of the original uu0 file, created on Dec. 3, 2014.

This file contains results which form a basis of the univalent
approach, and which do not require the use of universes as types.

Ported to coq trunk (8.4-8.5) in March 2014.  *)

(** ** Preambule *)

(** Settings *)

Unset Automatic Introduction. (* This line has to be removed for the file to compile with Coq8.2 *)



(** ** Imports *)

Require Export Foundations.Generalities.uuu.

(** ** Universe structure *)

Definition UU := Type.

Identity Coercion fromUUtoType : UU >-> Sortclass.

(* end of "Preambule". *)


(** ** Some standard constructions not using identity types (paths) *)

(** *** Canonical functions from [ empty ] and to [ unit ] *)

Definition fromempty  : forall X : UU , empty -> X.
Proof.
  intro X.
  intro H.  
  induction H.
Defined.

Arguments fromempty { X } _ . 

Definition tounit {X : UU} : X -> unit := fun (x : X) => tt.

(** *** Functions from [ unit ] corresponding to terms *)

Definition termfun {X : UU} (x : X) : unit -> X := fun (t : unit) => x.

(** *** Identity functions and function composition *)

Definition idfun (T : UU) := fun (t : T) => t.

Definition funcomp {X Y Z : UU} (f : X -> Y) (g : Y -> Z) := 
  fun (x : X) => g (f x).

Notation "g 'circ' f" := (funcomp f g) (at level 80, right associativity).

(** *** Iteration of an endomorphism *)

Definition iteration {T : UU} (f : T -> T) (n : nat) : T -> T.
Proof.
  intros T f n.
  induction n as [ | n IHn ].
  + exact (idfun T).
  + exact (f circ IHn).
Defined.

(** *** Basic constructions related to the adjoint evaluation 
  function [ X -> ((X -> Y) -> Y) ] *)

Definition adjev {X Y : UU} (x : X) (f : X -> Y) : Y := f x.

Definition adjev2 {X Y : UU} (phi : ((X -> Y) -> Y) -> Y) : X -> Y :=
  fun  (x : X) => phi (fun (f : X -> Y) => f x).

(** *** Pairwise direct products *)

Definition dirprod (X Y : UU) := total2 (fun x : X => Y).

Definition dirprodpair {X Y : UU} := tpair (fun x : X => Y).

Definition dirprodadj {X Y Z : UU} (f : dirprod X Y -> Z) : X -> Y -> Z :=  
  (fun (x : X) => (fun (y : Y) => f (dirprodpair x y))).

Definition dirprodf {X Y X' Y' : UU} 
  (f : X -> Y) (f' : X' -> Y') (xx' : dirprod X X')  : dirprod Y Y' :=
     dirprodpair (f (pr1 xx')) (f' (pr2 xx')).

Definition ddualand {X Y P : UU}
  (xp : (X -> P) -> P) (yp : (Y -> P) -> P) : (dirprod X Y -> P) -> P.
Proof. 
  intros X Y P xp yp X0.
  apply xp. intro x.
  apply yp. intro y.
  apply (X0 (dirprodpair x y)).
Defined.

(** *** Negation and double negation *)

Definition neg (X : UU) : UU := X -> empty.

Definition negf {X Y : UU} (f : X -> Y) : neg Y -> neg X := 
  fun (phi : Y -> empty) => fun (x : X) => phi (f x).

Definition dneg (X : UU) : UU := (X -> empty) -> empty.

Definition dnegf {X Y : UU} (f : X -> Y) : dneg X -> dneg Y :=
  negf (negf f).

Definition todneg (X : UU) : X -> dneg X := adjev.

Definition dnegnegtoneg { X : UU } : dneg (neg X) -> neg X := adjev2.

Lemma dneganddnegl1 {X Y : UU} (dnx : dneg X) (dny : dneg Y) : neg (X -> neg Y).
Proof.
  intros.
  intros X2.
  apply (dnegf X2).
  + apply dnx.
  + apply dny.
Defined.

Definition dneganddnegimpldneg {X Y : UU}
  (dnx : dneg X) (dny : dneg Y) : dneg (dirprod X Y) := ddualand dnx dny. 

(** *** Logical equivalence *)

Definition logeq (X Y : UU) := dirprod (X -> Y)  (Y -> X) .
Notation " X <-> Y " := (logeq X Y) : type_scope .  

Definition logeqnegs {X Y : UU} (l : X <-> Y ) : (neg X) <-> (neg Y) :=
  dirprodpair (negf (pr2 l)) (negf (pr1 l)). 

(* end of "Some standard constructions not using idenity types (paths)". *)


(** ** Operations on [ paths ] *)


Notation "a = b" := (paths a b) (at level 70, no associativity) : type_scope.


(** *** Composition of paths and inverse paths *)
 

Definition pathscomp0 {X : UU} {a b c : X} (e1 : a = b) (e2 : b = c) : a = c.
Proof.
  intros. induction e1. apply e2.
Defined.

Hint Resolve @pathscomp0 : pathshints.

(** Notation [p @ q] added by B.A., oct 2014 *)

Notation "p @ q" := (pathscomp0 p q) (at level 60, right associativity).


(* the end of Oct. 29, 2014 lecture *)

Definition pathscomp0rid {X : UU} {a b : X} (e1 : a = b) : e1 @ idpath b = e1 . 
Proof.
  intros. induction e1. simpl. apply idpath.
Defined. 

(** Note that we do no need [ pathscomp0lid ] since the corresponding
    two terms are convertible to each other due to our definition of
    [ pathscomp0 ]. If we defined it by inductioning [ e2 ] and
    applying [ e1 ] then [ pathsinv0rid ] would be trivial but
    [ pathsinv0lid ] would require a proof. Similarly we do not need a
    lemma to connect [ pathsinv0 ( idpath _ ) ] to [ idpath ].
 *)

Definition pathsinv0 {X : UU} {a b : X} (e : a = b) : b = a.
Proof.
  intros. induction e. apply idpath.
Defined.

Hint Resolve @pathsinv0 : pathshints .


(** Notation [! p] added by B.A., oct 2014 *)

Notation "! p " := (pathsinv0 p) (at level 50).


Definition pathsinv0l {X : UU} {a b : X} (e : a = b) : !e @ e = idpath _.
Proof.
  intros. induction e. apply idpath.
Defined.

Definition pathsinv0r {X : UU} {a b : X} (e : a = b) : e @ !e = idpath _.
Proof.
  intros. induction e. apply idpath.
Defined. 

Definition pathsinv0inv0 {X : UU} {x x' : X} (e : x = x') : !(!e) = e.
Proof.
  intros. induction e. apply idpath.
Defined.


(** *** Direct product of paths  *)


Definition pathsdirprod {X Y : UU} {x1 x2 : X} {y1 y2 : Y}
  (ex : x1 = x2) (ey : y1 = y2) : dirprodpair x1 y1 = dirprodpair x2 y2 .
Proof.
  intros. destruct ex. destruct ey. apply idpath.
Defined. 


(** *** The function [ maponpaths ] between paths types defined by a
    function between ambient types and its behavior relative to [ @ ]
    and [ ! ] *)

Definition maponpaths {T1 T2 : UU} (f : T1 -> T2) {t1 t2 : T1} 
  (e: t1 = t2) : f t1 = f t2.
Proof.
  intros. induction e. apply idpath.
Defined.

Definition maponpathscomp0 {X Y : UU} {x1 x2 x3 : X}
  (f : X -> Y) (e1 : x1 = x2) (e2 : x2 = x3) :
    maponpaths f (e1 @ e2) = maponpaths f e1 @ maponpaths f e2.
Proof.
  intros. induction e1. induction e2. simpl. apply idpath.
Defined. 

Definition maponpathsinv0 {X Y : UU} (f : X -> Y)
  {x1 x2 : X} (e : x1 = x2) : maponpaths f (! e) = ! (maponpaths f e).
Proof.
  intros. induction e. apply idpath.
Defined.


(** *** [ maponpaths ] for the identity functions and compositions of
    functions *)

Lemma maponpathsidfun {X : UU} {x x' : X}
  (e : x = x') : maponpaths (idfun _) e = e.
Proof.
  intros. induction e. apply idpath.
Defined. 

Lemma maponpathscomp {X Y Z : UU} {x x' : X} (f : X -> Y) (g : Y -> Z) 
  (e : x = x') : maponpaths g (maponpaths f e) = maponpaths (g circ f) e.
Proof.
  intros. induction e. apply idpath.
Defined. 

(** The following three statements show that [ maponpaths ] defined by
    a function f which is homotopic to the identity is
    "surjective". It is later used to show that the maponpaths defined
    by a function which is a weak equivalence is itself a weak
    equivalence. *)

Definition maponpathshomidinv {X : UU} (f : X -> X)
  (h : forall x : X, f x = x) (x x' : X) (e : f x = f x') : x = x' := 
    ! (h x) @ e @ (h x').

Lemma maponpathshomid1 {X : UU} (f : X -> X) (h: forall x : X, f x = x)
  {x x' : X} (e : x = x') : maponpaths f e = (h x) @ e @ (! h x').
Proof.
  intros. induction e. simpl.
  apply pathsinv0.
  apply pathsinv0r.
Defined.

Lemma maponpathshomid2 {X : UU} (f : X -> X) (h: forall x : X, f x = x)
  (x x' : X) (e: f x = f x') : maponpaths f (maponpathshomidinv f h _ _ e) = e.
Proof.
  intros.
  unfold maponpathshomidinv.
  apply (pathscomp0 (maponpathshomid1 f h (! h x @ e @ h x'))).

  (* We prove a little lemma first. *)
  assert (l : forall X : UU, forall a b c d : X,
            forall p : a = b, forall q : a = c, forall r : c = d,
               p @ (!p @ q @ r) @ !r = q).
  { intros. induction p. induction q. induction r. apply idpath. }

  apply (l _ _ _ _ _ (h x) e (h x')).
Defined.

(** Here we consider the behavior of maponpaths in the case of a
    projection [ p ] with a section [ s ]. *)

Definition pathssec1 {X Y : UU} (s : X -> Y) (p : Y -> X)
  (eps : forall (x : X) , p (s x) = x) 
    (x : X) (y : Y) (e : s x = y) : x = p y.
Proof.
  intros.
  apply (pathscomp0 (! eps x)).
  apply (maponpaths p e).
Defined.

Definition pathssec2 {X Y : UU} (s : X -> Y) (p : Y -> X)
  (eps : forall (x : X), p (s x) = x)
    (x x' : X) (e : s x = s x') : x = x'.
Proof.
  intros.
  set (e' := pathssec1 s p eps _ _ e).
  apply (e' @ (eps x')).
Defined.

Definition pathssec2id {X Y : UU} (s : X -> Y) (p : Y -> X)
  (eps : forall x : X, p (s x) = x)
    (x : X) : pathssec2 s p eps _ _ (idpath (s x)) = idpath x.
Proof.
  intros.
  unfold pathssec2. unfold pathssec1. simpl.
  assert (e : forall X : UU, forall a b : X,
    forall p : a = b, (! p @ idpath _) @ p = idpath _).
  { intros. induction p0. simpl. apply idpath. }
  apply e.
Defined.

Definition pathssec3 {X Y : UU} (s : X -> Y) (p : Y -> X) 
  (eps : forall x : X, p (s x) = x) {x x' : X} (e : x = x') : 
    pathssec2 s p eps  _ _ (maponpaths s e) = e.
Proof.
  intros. induction e. simpl.
  apply pathssec2id.
Defined.

(* end of "Operations on [ paths ]". *) 


(** ** Fibrations and paths *)

Definition tppr {T : UU} {P : T -> UU}
  (x : total2 P) : x = tpair _ (pr1 x) (pr2 x).
Proof.
  intros. induction x. simpl.
  apply idpath.
Defined.

Definition constr1 {X : UU} (P : X -> UU) {x x' : X} (e : x = x') :
  total2 (fun (f : P x -> P x') =>
    total2 (fun (ee : forall p : P x, tpair _ x p = tpair _ x' (f p)) =>
      forall pp : P x, maponpaths pr1 (ee pp) = e)). 
Proof.
  intros. induction e.
  split with (idfun (P x)).
  split with (fun p : P x => idpath _).
  unfold maponpaths. simpl.
  intro. apply idpath.
Defined.

Definition transportf {X : UU} (P : X -> UU) {x x' : X}
  (e : x = x') : P x -> P x' := pr1 (constr1 P e).

Definition transportb {X : UU} (P : X -> UU) {x x' : X}
  (e : x = x') : P x' -> P x := transportf P (!e).

Lemma functtransportf {X Y : UU} (f : X -> Y) (P : Y -> UU) {x x' : X}
  (e : x = x') (p : P (f x)) :
    transportf (fun x => P (f x)) e p = transportf P (maponpaths f e) p.
Proof.
  intros. induction e. apply idpath.
Defined.

(** A series of lemmas about paths and sigma types.
    Adapted from the HoTT library http://github.com/HoTT/HoTT *)

Lemma base_paths {A : UU} {B : A -> UU} 
  (a b : total2 B) : a = b -> pr1 a = pr1 b.
Proof.
  intros.
  apply maponpaths; assumption.
Defined.

Lemma total2_paths {A : UU} {B : A -> UU} {s s' : total2 (fun x => B x)} 
    (p : pr1 s = pr1 s') 
    (q : transportf (fun x => B x) p (pr2 s) = pr2 s') : s = s'.
Proof.
  intros.
  induction s as [a b].
  induction s' as [a' b']; simpl in *.
  induction p.
  induction q. 
  apply idpath.
Defined.

Lemma total2_paths2 {A : UU} {B : A -> UU} {a1 : A} {b1 : B a1} 
  {a2 : A} {b2 : B a2} (p : a1 = a2) 
    (q : transportf (fun x => B x) p b1 = b2) : 
      tpair (fun x => B x) a1 b1 = tpair (fun x => B x) a2 b2.
Proof.
  intros.
  apply (@total2_paths _ _
    (tpair (fun x => B x) a1 b1) (tpair (fun x => B x) a2 b2) p q).
Defined.

Definition fiber_paths {A : UU} {B : A -> UU} {u v : total2 (fun x => B x)}
  (p : u = v) : transportf (fun x => B x) (base_paths _ _ p) (pr2 u) = pr2 v.
Proof.
  induction p.
  apply idpath.
Defined.

Lemma total2_fiber_paths {A : UU} {B : A -> UU} {x y : total2 (fun x => B x)} 
  (p : x = y) : total2_paths  _ (fiber_paths p) = p.
Proof.
  induction p.
  induction x.
  apply idpath.
Defined.

Lemma base_total2_paths {A : UU} {B : A -> UU} {x y : total2 (fun x => B x)}
  {p : pr1 x = pr1 y} (q : transportf _ p (pr2 x) = pr2 y) :
    (base_paths _ _ (total2_paths _ q)) = p.
Proof.
  induction x as [x H]. 
  induction y as [y K].
  simpl in *. 
  induction p.  
  induction q.
  apply idpath.
Defined.


Lemma transportf_fiber_total2_paths {A : UU} (B : A -> UU)
  (x y : total2 (fun x => B x))
    (p : pr1 x = pr1 y) (q : transportf _ p (pr2 x) = pr2 y) :
      transportf (fun p' : pr1 x = pr1 y => transportf _ p' (pr2 x) = pr2 y)
      (base_total2_paths q)  (fiber_paths (total2_paths _ q)) = q.
Proof.
  induction x as [x H]. 
  induction y as [y K].
  simpl in *. 
  induction p. 
  induction q.
  apply idpath.
Defined.


(** Lemmas about transport 
    Adapted from the HoTT library and the HoTT book
*)

Definition transportD {A : UU} (B : A -> UU) (C : forall a : A, B a -> UU)
  {x1 x2 : A} (p : x1 = x2) (y : B x1) (z : C x1 y) : C x2 (transportf _ p y).
Proof.  
  intros.
  induction p. 
  exact z.
Defined.


Definition transportf_total2 {A : UU} {B : A -> UU} {C : forall a:A, B a -> UU}
  {x1 x2 : A} (p : x1 = x2) (yz : total2 (fun y : B x1 => C x1 y )) : 
    transportf (fun x => total2 (fun y : B x => C x y)) p yz = 
     tpair (fun y => C x2 y) (transportf _ p  (pr1 yz))
                             (transportD _ _ p (pr1 yz) (pr2 yz)).
Proof.
  intros.
  induction p. 
  induction yz. 
  apply idpath.
Defined.

Definition transportf_dirprod (A : UU) (B B' : A -> UU) 
  (x x' : total2 (fun a => dirprod (B a) (B' a)))  (p : pr1 x = pr1 x') :
  transportf (fun a => dirprod (B a) (B' a)) p (pr2 x) = 
    dirprodpair (transportf (fun a => B a) p (pr1 (pr2 x))) 
                (transportf (fun a => B' a) p (pr2 (pr2 x))).
Proof.
  induction p.
  apply tppr.
Defined.

Definition transportf_id1 {A : UU} {B : A -> UU} {a x1 x2 : A}
  (p : x1 = x2) (q : a = x1) : 
    transportf (fun (x : A) => a = x) p q = q @ p.
Proof.
  intros. induction p. induction q. apply idpath.
Defined.

Definition transportf_id2 {A : UU} {B : A -> UU} {a x1 x2 : A}
  (p : x1 = x2) (q : x1 = a) : 
    transportf (fun (x : A) => x = a) p q = !p @ q.
Proof.
  intros. induction p. induction q. apply idpath.
Defined.

Definition transportf_id3 {A : UU} {B : A -> UU} {x1 x2 : A}
  (p : x1 = x2) (q : x1 = x1) : 
    transportf (fun (x : A) => x = x) p q = !p @ q @ p.
Proof.
  intros. induction p. simpl. apply pathsinv0. apply pathscomp0rid.
Defined.

(** ** First homotopy notions *)

(** *** Homotopy between functions *)

Definition homot {X : UU} {P : X -> UU} (f g : forall x : X, P x) :=
  forall x : X , f x = g x.

Notation "f ~ g" := (homot f g) (at level 70, right associativity).

Definition homotcomp {X Y : UU} {f f' f'' : X -> Y}
  (h : f ~ f') (h' : f' ~ f'') : f ~ f'' := fun (x : X) => h x @ h' x.

Definition invhomot {X Y : UU} {f f' : X -> Y}
  (h : f ~ f' ) : f' ~ f := fun (x : X) => !(h x).

Definition funhomot {X Y Z : UU} (f : X -> Y) {g g' : Y -> Z}
  (h : g ~ g' ) : (g circ f) ~ (g' circ f) := fun (x : X) => h (f x) .

Definition homotfun {X Y Z : UU} {f f' : X -> Y} (h : f ~ f')
  (g : Y -> Z) : (g circ f) ~ (g circ f') := fun (x : X) => maponpaths g (h x).
 

(** *** Contractibility, homotopy fibers etc. *)

(** Contractible types. *)

Definition iscontr (T : UU) : UU := 
  total2 (fun (cntr : T)  => forall (t : T), t = cntr).

Definition iscontrpair {T : UU} :
  forall x : T, (forall t : T, t = x) -> iscontr T := 
    tpair (fun (cntr : T) => forall t : T, t = cntr).

Definition iscontrpr1 {T : UU} :=
  @pr1 T (fun (cntr : T) => forall t : T, t = cntr).

Lemma iscontrretract {X Y : UU} (p : X -> Y) (s : Y -> X) 
  (eps : forall y : Y, p (s y) = y) (is : iscontr X) : iscontr Y.
Proof.
  intros.
  induction is as [x fe].
  split with (p x).
  intro t.
  apply (! (eps t) @ maponpaths p (fe (s t))).
Defined.    

Lemma proofirrelevancecontr {X : UU} (is : iscontr X) (x x' : X) : x = x'.
Proof.
  intros.
  induction is as [y fe].
  apply (fe x @ !(fe x')).
Defined.
  
(** Coconuses: spaces of paths which begin (coconusfromt) or end (coconustot)
    at a given point. *)

Definition coconusfromt (T : UU) (t : T) :=
  total2 (fun (t' : T) => t = t').

Definition coconusfromtpair (T : UU) {t t' : T}
  (e: t = t') : coconusfromt T t :=
    tpair (fun (t' : T) => t = t') t' e.

Definition coconusfromtpr1 (T : UU) (t : T) := @pr1 _ (fun (t' : T) => t' = t).

Definition coconustot (T : UU) (t : T) := 
  total2 (fun (t' : T) => t' = t).

Definition coconustotpair (T : UU) {t t' : T}
  (e: t' = t) : coconustot T t :=
    tpair (fun (t' : T) => t' = t) t' e.

Definition coconustotpr1 (T : UU) (t : T) := @pr1 _ (fun (t' : T) => t' = t). 

(* There is a path between any two paths in a coconus. As we also
   have a trivial path, namely the one that starts at t and ends at t,
   the space of coconuses is contractible. *)

Lemma connectedcoconustot {T : UU} {t : T} (c1 c2 : coconustot T t) : c1 = c2.
Proof.
  intros.
  induction c1 as [x0 x].
  induction x.
  induction c2 as [x1 y].
  induction y.
  apply idpath.
Defined. 

Lemma iscontrcoconustot (T : UU) (t : T) : iscontr (coconustot T t).
Proof.
  intros.
  unfold iscontr.
  split with (tpair (fun (t' : T) => t' = t) t (idpath t)).
  intros.
  apply connectedcoconustot.
Defined.

Lemma connectedcoconusfromt {T : UU} {t : T} (c1 c2 : coconusfromt T t) :
  c1 = c2.
Proof.
  intros.
  induction c1 as [x0 x].
  induction x.
  induction c2 as [x1 y].
  induction y.
  apply idpath.
Defined.

Lemma iscontrcoconusfromt (T : UU) (t : T) : iscontr (coconusfromt T t).
Proof.
  intros. unfold iscontr.
  split with (tpair (fun (t' : T) => t = t') t (idpath t)).
  intros. 
  apply connectedcoconusfromt.
Defined.

(** Paths space of a type: a point t, and the coconus from it. *)

Definition pathsspace (T : UU) := total2 (fun (t : T) => coconusfromt T t).

Definition pathsspacetriple (T : UU) {t1 t2 : T}
  (e : t1 = t2) : pathsspace T := tpair _ t1 (coconusfromtpair T e).

Definition deltap (T : UU) : T -> pathsspace T := 
  fun (t : T) => pathsspacetriple T (idpath t).

Definition pathsspace' (T : UU) := 
  total2 (fun (xy : dirprod T T) => pr1 xy = pr2 xy).

(** Homotopy fibers. *)

Definition hfiber {X Y : UU}  (f : X -> Y) (y : Y) : UU := 
  total2 (fun (pointover : X) => f pointover = y).
 
Definition hfiberpair {X Y : UU} (f : X -> Y) {y : Y}
  (x : X) (e : f x = y) : hfiber f y := 
    tpair (fun (pointover : X) => f pointover = y) x e.

Definition hfiberpr1 {X Y : UU} (f : X -> Y) (y : Y) :=
  @pr1 _ (fun (pointover : X) => f pointover = y).

(** Paths in homotopy fibers. *)

Lemma hfibertriangle1 {X Y : UU} (f : X -> Y) {y : Y} {xe1 xe2 : hfiber f y}
  (e : xe1 = xe2) :
    pr2 xe1 = maponpaths f (maponpaths pr1 e) @ pr2 xe2.
Proof.
  intros. induction e. simpl. apply idpath.
Defined.

Lemma hfibertriangle1inv0 {X Y : UU} (f : X -> Y) {y : Y} {xe1 xe2: hfiber f y}
  (e : xe1 = xe2) :
    maponpaths f (! (maponpaths pr1 e)) @ (pr2 xe1) = pr2 xe2. 
Proof.
  intros. induction e. apply idpath.
Defined.

Lemma hfibertriangle2 {X Y : UU} (f : X -> Y) {y : Y} (xe1 xe2: hfiber f y)
  (ee: pr1 xe1 = pr1 xe2) (eee: pr2 xe1 = maponpaths f ee @ (pr2 xe2)) :
    xe1 = xe2.
Proof.
  intros.
  induction xe1 as [t e1].
  induction xe2 as [t' e2].
  simpl in *.
  fold (hfiberpair f t e1).
  fold (hfiberpair f t' e2).
  induction ee.
  simpl in eee.
  apply (maponpaths (fun e: paths (f t) y => hfiberpair f t e) eee).
Defined.

(** Coconus of a function: the total space of the family of h-fibers.
    The coconus behaves like the image of a function.  *)

Definition coconusf {X Y : UU} (f : X -> Y) :=
  total2 (fun (y : Y) => hfiber f y).

Definition fromcoconusf {X Y : UU} (f : X -> Y) : coconusf f -> X := 
  fun (yxe : coconusf f) => pr1 (pr2 yxe).

Definition tococonusf {X Y : UU} (f : X -> Y) : X -> coconusf f :=
  fun (x : _) => tpair _ (f x) (hfiberpair f x (idpath _ )).

Lemma homottofromcoconusf {X Y : UU} (f : X -> Y) :
  forall yxe : coconusf f, tococonusf f (fromcoconusf f yxe) = yxe.
Proof.
  intros.
  induction yxe as [y xe].
  induction xe as [x e].
  unfold fromcoconusf.
  unfold tococonusf.
  simpl.
  induction e.
  apply idpath.
Defined.

Lemma homotfromtococonusf {X Y : UU} (f : X -> Y) :
  forall x : X, fromcoconusf f (tococonusf f x) = x.
Proof.
  intros.
  unfold fromcoconusf.
  unfold tococonusf.
  simpl.
  apply idpath.
Defined.

(** Total spaces of families and homotopies *)

Definition famhomotfun {X : UU} {P Q : X -> UU}
  (h : P ~ Q) (xp : total2 P) : total2 Q. 
Proof.
  intros.
  induction xp as [ x p ].
  split with x.
  induction (h x). 
  apply p.
Defined.

Definition famhomothomothomot {X : UU} {P Q : X -> UU} (h1 h2 : P ~ Q)
  (H : h1 ~ h2) : famhomotfun h1 ~ famhomotfun h2.
Proof.
  intros.
  intro xp.
  induction xp as [x p].
  simpl.
  apply (maponpaths (fun q => tpair Q x q)).
  induction (H x).
  apply idpath.
Defined. 


(** ** Weak equivalences *)

(** *** Basics *)

Definition isweq {X Y : UU} (f : X -> Y) : UU :=
  forall y : Y, iscontr (hfiber f y).

Lemma idisweq (T : UU) : isweq (idfun T).
Proof.
  intros. unfold isweq. intro y.
  unfold iscontr.
  split with (tpair (fun (x : T) => idfun T x = y) y (idpath y)).
  intro t.
  induction t as [x e].
  induction e.
  apply idpath.
Defined. 

Definition weq (X Y : UU) : UU :=
  total2 (fun (f : X -> Y) => isweq f).

Definition pr1weq {X Y : UU} := @pr1 _ _ : weq X Y -> (X -> Y).
Coercion pr1weq : weq >-> Funclass.

Definition weqccontrhfiber {X Y : UU} (w : weq X Y) (y : Y) : hfiber w y.
Proof.
  intros. apply (pr1 (pr2 w y)).
Defined.

Definition weqccontrhfiber2 {X Y : UU} (w : weq X Y) (y : Y) :
  forall x : hfiber w y, x = weqccontrhfiber w y.
Proof.
  intros. unfold weqccontrhfiber. apply (pr2 (pr2 w y)).
Defined. 

Definition weqpair {X Y : UU} (f : X -> Y) (is: isweq f) : weq X Y :=
  tpair (fun (f : X -> Y) => isweq f) f is.
 
Definition idweq (X : UU) : weq X X :=
  tpair (fun (f : X -> X) => isweq f) (fun (x : X) => x) (idisweq X).

Definition isweqtoempty {X : UU} (f : X -> empty) : isweq f.
Proof.
  intros. intro y. apply (fromempty y).
Defined.

Definition weqtoempty {X : UU} (f : X -> empty) :=
  weqpair _ (isweqtoempty f).

Lemma isweqtoempty2 {X Y : UU} (f : X -> Y) (is : neg Y) : isweq f.
Proof.
  intros. intro y. induction (is y).
Defined. 

Definition weqtoempty2 {X Y : UU} (f : X -> Y) (is : neg Y) :=
  weqpair _ (isweqtoempty2 f is).

Definition invmap {X Y : UU} (w : weq X Y) : Y -> X :=
  fun (y : Y) => pr1 (weqccontrhfiber w y).

(** We now define different homotopies and maps between the paths
    spaces corresponding to a weak equivalence. What may look like
    unnecessary complexity in the definition of [ weqgf ] is due to the
    fact that the "naive" definition, that of [ weqgf00 ], needs to be
    corrected in order for lemma [ weqfgf ] to hold. *)

Definition homotweqinvweq {X Y : UU} (w : weq X Y) :
  forall y : Y, w (invmap w y) = y.
Proof.
  intros.
  unfold invmap.
  apply (pr2 (weqccontrhfiber w y)).
Defined.

Definition homotinvweqweq0 {X Y : UU} (w : weq X Y) :
 forall x : X, x = invmap w (w x).
Proof.
  intros.
  unfold invmap.
  set (xe1 := weqccontrhfiber w (w x)).
  set (xe2 := hfiberpair w x (idpath (w x))).
  set (p := weqccontrhfiber2 w (w x) xe2).
  apply (maponpaths pr1 p).
Defined.

Definition homotinvweqweq {X Y : UU} (w : weq X Y) :
  forall x : X, invmap w (w x) = x :=
    fun (x : X) => ! (homotinvweqweq0 w x).

Lemma diaglemma2 {X Y : UU} (f : X -> Y) {x x' : X}
  (e1 : x = x') (e2 : f x' = f x)
    (ee : idpath (f x) = maponpaths f e1 @ e2) : maponpaths f (! e1) = e2.
Proof.
  intros. induction e1. simpl in *. apply ee.
Defined.

Definition homotweqinvweqweq {X Y : UU} (w : weq X Y) (x : X) :
  maponpaths w (homotinvweqweq w x) = homotweqinvweq w (w x).
Proof.
  intros.
  unfold homotinvweqweq.
  unfold homotinvweqweq0.
  set (hfid := hfiberpair w x (idpath (w x))).
  set (hfcc := weqccontrhfiber w (w x)).
  unfold homotweqinvweq.
  apply diaglemma2.
  apply (@hfibertriangle1 _ _ w _ hfid hfcc (weqccontrhfiber2 w (w x) hfid)).
Defined.

Definition invmaponpathsweq {X Y : UU} (w : weq X Y) (x x' : X) : 
  w x = w x' -> x = x' :=
    pathssec2 w (invmap w) (homotinvweqweq w) x x'.

Definition invmaponpathsweqid {X Y : UU} (w : weq X Y) (x : X) : 
  invmaponpathsweq w _ _ (idpath (w x)) = idpath x :=
    pathssec2id w (invmap w) (homotinvweqweq w) x.

Definition pathsweq1 {X Y : UU} (w : weq X Y) (x : X) (y : Y) :
  w x = y -> x = invmap w y :=
    pathssec1 w (invmap w) (homotinvweqweq w) _ _.

Definition pathsweq1' {X Y : UU} (w : weq X Y) (x : X) (y : Y)
  (e : x = invmap w y) : w x = y :=
    maponpaths w e @ homotweqinvweq w y.

Definition pathsweq3 {X Y : UU} (w : weq X Y) {x x' : X} 
  (e : x = x') : invmaponpathsweq w x x' (maponpaths w e) = e :=
    pathssec3 w (invmap w) (homotinvweqweq w) _.

Definition pathsweq4 {X Y : UU} (w : weq X Y) (x x' : X)
  (e : w x = w x') : maponpaths w (invmaponpathsweq w x x' e) = e.
Proof.
  intros.
  destruct w as [f is1].
  set (w := weqpair f is1).
  set (g := invmap w).
  set (ee := maponpaths g e).
  simpl in *.
  set (eee := maponpathshomidinv (g circ f) (homotinvweqweq w) x x' ee).
  
  assert (e1 : maponpaths f eee = e).
  {
    assert (e2 : maponpaths (g circ f) eee = ee).
    apply maponpathshomid2.
    assert (e3 : maponpaths g (maponpaths f eee) = maponpaths g e).
    apply (maponpathscomp f g eee @ e2).
    set (s := @maponpaths _ _ g (f x) (f x')).
    set (p := @pathssec2  _ _ g f (homotweqinvweq w) (f x) (f x')).
    set (eps := @pathssec3  _ _ g f (homotweqinvweq w ) (f x) (f x')).
    apply (pathssec2 s p eps _ _  e3).
  }
 
  assert (e4: 
    maponpaths f  (invmaponpathsweq w x x' (maponpaths f eee)) =
      maponpaths f (invmaponpathsweq w x x' e)).
  { 
    apply (maponpaths (fun (e0: f x = f x') =>
                       maponpaths f (invmaponpathsweq w x x' e0))
           e1).
  }

  assert (X0 : invmaponpathsweq w x x' (maponpaths f eee) = eee).
  { apply (pathsweq3 w). }

  assert (e5: maponpaths f (invmaponpathsweq w x x' (maponpaths f eee))
              = maponpaths f eee).
  { apply (maponpaths (fun eee0: x = x' => maponpaths f eee0) X0). }

  apply (! e4 @ e5 @ e1).
Defined. 

(** *** Weak equivalences between contractible types (other
        implications are proved below). *)

Lemma iscontrweqb {X Y : UU} (w : weq X Y) (is : iscontr Y) : iscontr X.
Proof.
  intros. apply (iscontrretract (invmap w) w (homotinvweqweq w) is).
Defined.

(** *** Functions between fibers defined by a path on the base are
        weak equivalences. *)

Lemma isweqtransportf {X : UU} (P : X -> UU) {x x' : X}
  (e : x = x') : isweq (transportf P e).
Proof.
  intros. induction e. unfold transportf. simpl. apply idisweq.
Defined.

Lemma isweqtransportb {X : UU} (P : X -> UU) {x x' : X}
  (e : x = x') : isweq (transportb P e).
Proof.
  intros. apply (isweqtransportf _ (pathsinv0 e)).
Defined.

(** *** [ unit ] and contractibility *)

(** [ unit ] is contractible (recall that [ tt ] is the name of the
    canonical term of the type [ unit ]). *)

Lemma isconnectedunit : forall x x' : unit, x = x'.
Proof.
  intros. induction x. induction x'. apply idpath.
Defined.

Lemma unitl0 : tt = tt -> coconustot _ tt.
Proof.
  intros e. apply (coconustotpair unit e).
Defined.

Lemma unitl1: coconustot _ tt -> tt = tt.
Proof.
  intro cp. induction cp as [x t]. induction x. apply t.
Defined.

Lemma unitl2: forall e : tt = tt, unitl1 (unitl0 e) = e.
Proof.
  intros. unfold unitl0. simpl. apply idpath.
Defined.

Lemma unitl3: forall e : tt = tt, e = idpath tt.
Proof.
  intros.
  
  assert (e0 : unitl0 (idpath tt) = unitl0 e).
  { apply connectedcoconustot. }

  set (e1 := maponpaths unitl1 e0).

  apply (! (unitl2 e) @ (! e1) @ (unitl2 (idpath _))).
Defined.

Theorem iscontrunit: iscontr (unit).
Proof.
  split with tt. intros t. apply (isconnectedunit t tt). 
Defined.

(** [ paths ] in [ unit ] are contractible. *)

Theorem iscontrpathsinunit (x x' : unit) : iscontr (x = x').
Proof.
  intros.
  split with (isconnectedunit x x').
  intros e'.
  induction x.
  induction x'.
  simpl.
  apply unitl3.
Defined.

(** A type [ T : UU ] is contractible if and only if [ T -> unit ] is
    a weak equivalence. *)

Lemma ifcontrthenunitl0 (e1 e2 : tt = tt) : e1 = e2.
Proof.
  intros.
  apply proofirrelevancecontr.
  apply (iscontrpathsinunit tt tt).
Defined.
  
Lemma isweqcontrtounit {T : UU} (is : iscontr T) : isweq (fun (t : T) => tt).
Proof.
  intros. unfold isweq. intro y. induction y.
  destruct is as [c h].
  set (hc := hfiberpair _ c (isconnectedunit tt tt)).
  split with hc.
  intros ha.
  induction ha as [x e].
  unfold hc. unfold hfiberpair. unfold isconnectedunit.
  simpl.
  apply (fun q => total2_paths2 (h x) q).
  apply ifcontrthenunitl0.
Defined.

Definition weqcontrtounit {T : UU} (is : iscontr T) : weq T unit :=
  weqpair _ (isweqcontrtounit is). 

Theorem iscontrifweqtounit {X : UU} (w : weq X unit) : iscontr X.
Proof.
  intros.
  apply (iscontrweqb w).
  apply iscontrunit.
Defined.

(** *** A homotopy equivalence is a weak equivalence *)

Definition hfibersgftog {X Y Z : UU} (f : X -> Y) (g : Y -> Z) (z : Z)
  (xe : hfiber (g circ f) z) : hfiber g z :=
    hfiberpair g (f (pr1 xe)) (pr2 xe).

Lemma constr2 {X Y : UU} (f : X -> Y) (g : Y -> X) 
  (efg: forall y : Y, f (g y) = y) (x0 : X) (xe : hfiber g x0) :
    total2 (fun (xe' : hfiber (g circ f) x0) => xe = hfibersgftog f g x0 xe').
Proof.
  intros.
  destruct xe as [y0 e].
  set (eint := pathssec1 _ _ efg _ _ e).
  set (ee := ! (maponpaths g eint) @ e).
  split with (hfiberpair (g circ f) x0 ee).
  unfold hfibersgftog.
  unfold hfiberpair.
  simpl.
  apply (total2_paths2 eint).
  induction eint.
  apply idpath.
Defined.

Lemma iscontrhfiberl1 {X Y : UU} (f : X -> Y) (g : Y -> X)
  (efg: forall y : Y, f (g y) = y) (x0 : X) 
    (is : iscontr (hfiber (g circ f) x0)) : iscontr (hfiber g x0).
Proof.
  intros.
  set (f1 := hfibersgftog f g x0).
  set (g1 := fun (xe : hfiber g x0) => pr1 (constr2 f g efg x0 xe)). 
  set (efg1 := fun (xe : hfiber g x0) => ! (pr2 (constr2 f g efg x0 xe))).
  apply (iscontrretract f1 g1 efg1).
  apply is.
Defined.

Definition homothfiber1 {X Y : UU} (f g : X -> Y)
  (h : f ~ g) (y : Y) (xe : hfiber f y) : hfiber g y.
Proof.
  intros. induction xe as [x e].
  apply (hfiberpair g x (!(h x) @ e)).
Defined.

Definition homothfiber2 {X Y : UU} (f g : X -> Y)
  (h : f ~ g) (y : Y) (xe : hfiber g y) : hfiber f y.
Proof.
  intros. induction xe as [x e].
  apply (hfiberpair f x (h x @ e)).
Defined.

Definition homothfiberretr {X Y : UU} (f g : X -> Y)
  (h : f ~ g) (y : Y) (xe : hfiber g y) :
    homothfiber1 f g h y (homothfiber2 f g h y xe) = xe.
Proof.
  intros.
  induction xe as [x e].
  simpl.
  fold (hfiberpair g x e).
  set (xe1 := hfiberpair g x (! h x @ h x @ e)).
  set (xe2 := hfiberpair g x e).
  apply (hfibertriangle2 g xe1 xe2 (idpath _)).
  simpl.

  (* Now, a little lemma: *)
  assert (ee : forall a b c : Y, forall p : a = b, forall q : b = c,
    !p @ (p @ q) = q).
  { intros. induction p. induction q. apply idpath. }
  
  apply ee.
Defined.

Lemma iscontrhfiberl2 {X Y : UU} (f g : X -> Y) 
  (h : f ~ g) (y : Y) (is : iscontr (hfiber f y)) : iscontr (hfiber g y).
Proof.
  intros.
  set (a := homothfiber1 f g h y).
  set (b := homothfiber2 f g h y).
  set (eab := homothfiberretr f g h y).
  apply (iscontrretract a b eab is).
Defined.  

Corollary isweqhomot {X Y : UU} (f1 f2 : X -> Y)
  (h : f1 ~ f2) : isweq f1 -> isweq f2.
Proof.
  intros X Y f1 f2 h x0.
  unfold isweq.
  intro y.
  apply (iscontrhfiberl2 f1 f2 h).
  apply x0.
Defined.

Theorem gradth {X Y : UU} (f : X -> Y) (g : Y -> X)
  (egf: forall x : X, g (f x) = x)
  (efg: forall y : Y, f (g y) = y) : isweq f.
Proof.
  intros.
  unfold isweq.
  intro y.
  assert (iscontr (hfiber (f circ g) y)).
  assert (efg' : forall y : Y, y = f (g y)).
  { intro y0.
    apply pathsinv0.    
    apply (efg y0). }
  apply (iscontrhfiberl2 (idfun _) (f circ g) efg' y (idisweq Y y)).
  apply (iscontrhfiberl1 g f egf y). 
  apply X0.
Defined.

Definition weqgradth {X Y : UU} (f : X -> Y) (g : Y -> X)
  (egf: forall x : X, g (f x) = x)
  (efg: forall y : Y, f (g y) = y) : weq X Y :=
    weqpair _ (gradth _ _ egf efg). 
 

(** *** Some basic weak equivalences *)

Corollary isweqinvmap {X Y : UU} (w : weq X Y) : isweq (invmap w).
Proof.
  intros.
  assert (efg : forall (y : Y), w (invmap w y) = y).
  apply homotweqinvweq.
  assert (egf : forall (x : X), invmap w (w x) = x).
  apply homotinvweqweq.
  apply (gradth _ _ efg egf).
Defined.

Definition invweq {X Y : UU} (w : weq X Y) : weq Y X :=
  weqpair (invmap w) (isweqinvmap w).

Corollary invinv {X Y :UU} (w : weq X Y) (x : X)  :
  invmap (invweq w) x = w x.
Proof.
  intros. apply idpath.
Defined.

Corollary iscontrweqf {X Y : UU} (w : weq X Y) (is : iscontr X) : iscontr Y.
Proof.
  intros. apply (iscontrweqb (invweq w) is).
Defined.

(** Equality between pairs is equivalent to pairs of equalities
    between components. Theorem adapted from HoTT library
    http://github.com/HoTT/HoTT.
 *)

Theorem total2_paths_equiv {A : UU} (B : A -> UU)
  (x y : total2 (fun x => B x)) :
    weq (x = y)
        (total2 (fun p : pr1 x = pr1 y => transportf _ p (pr2 x) = pr2 y)).
Proof.
  intros A B x y.
  exists (fun (r : x = y) =>  
            tpair (fun p : pr1 x = pr1 y => transportf _ p (pr2 x) = pr2 y)
              (base_paths _ _ r) (fiber_paths r)).
  apply (gradth _
    (fun (pq : total2 (fun (p : pr1 x = pr1 y) => 
               transportf _ p (pr2 x) = pr2 y)) => 
       total2_paths (pr1 pq) (pr2 pq))).
  - intro p.
    apply total2_fiber_paths.
  - intros [p q]. simpl in *.
    apply (total2_paths2 (base_total2_paths q)).
    apply transportf_fiber_total2_paths.
Defined.

(** The standard weak equivalence from [ unit ] to a contractible type *)

Definition wequnittocontr {X : UU} (is : iscontr X) : weq unit X.
Proof.
  intros.
  set (f := fun (t : unit) => pr1 is).
  set (g := fun (x : X) => tt).
  split with f.
  assert (egf : forall t : unit, g (f t) = t).
  { intro. induction t. apply idpath. }
  assert (efg : forall x : X, f (g x) = x).
  { intro. apply (! (pr2 is x)). }
  apply (gradth _ _ egf efg).
Defined.

(** A weak equivalence between types defines weak equivalences on the
    corresponding [ paths ] types. *)

Corollary isweqmaponpaths {X Y : UU} (w : weq X Y) (x x' : X) :
  isweq (@maponpaths _ _ w x x').
Proof.
  intros.
  apply (gradth (@maponpaths _ _ w x x')
                (@invmaponpathsweq _ _ w x x')
                (@pathsweq3 _ _ w x x')
                (@pathsweq4 _ _ w x x')).
Defined.

Definition weqonpaths {X Y : UU} (w : weq X Y) (x x' : X) :=
  weqpair _ (isweqmaponpaths w x x').

Corollary isweqpathsinv0 {X : UU} (x x' : X) : isweq (@pathsinv0 _ x x').
Proof.
  intros.
  apply (gradth (@pathsinv0 _ x x')
                (@pathsinv0 _ x' x)
                (@pathsinv0inv0 _ _ _  )
                (@pathsinv0inv0  _ _ _ )).
Defined.

Definition weqpathsinv0 {X : UU} (x x' : X) :=
  weqpair _ (isweqpathsinv0 x x').

Corollary isweqpathscomp0r {X : UU} (x : X) {x' x'' : X} (e': x' = x'') :
   isweq (fun (e : x = x') => e @ e').
Proof.
  intros.
  set (f := fun (e : x = x') => e @ e').
  set (g := fun (e'' : x = x'') => e'' @ (! e')).
  assert (egf : forall e : _, g (f e) = e).
  { intro e. induction e. induction e'. apply idpath. }
  assert (efg : forall e : _, f (g e) = e).
  { intro e. induction e. induction e'. apply idpath. }
  apply (gradth f g egf efg).
Defined.

Corollary isweqtococonusf {X Y : UU} (f : X -> Y): isweq (tococonusf f).
Proof.
  intros.
  apply (gradth _ _ (homotfromtococonusf f) (homottofromcoconusf f)).
Defined.

Definition weqtococonusf {X Y : UU} (f : X -> Y) : weq X (coconusf f) := 
  weqpair _ (isweqtococonusf f).

Corollary  isweqfromcoconusf {X Y : UU} (f : X -> Y): isweq (fromcoconusf f).
Proof.
  intros.
  apply (gradth _ _ (homottofromcoconusf f) (homotfromtococonusf f)).
Defined.

Definition weqfromcoconusf {X Y : UU} (f : X -> Y) : weq (coconusf f) X :=
  weqpair _ (isweqfromcoconusf f).

Corollary isweqdeltap (T : UU) : isweq (deltap T).
Proof.
  intros.
  set (ff := deltap T). set (gg := fun (z : pathsspace T) => pr1 z).
  assert (egf : forall t : T, gg (ff t) = t).
  { intro. apply idpath. }
  assert (efg : forall (tte : _), ff (gg tte) = tte).
  { intro tte. induction tte as [t c].
    induction c as [x e]. induction e.
    apply idpath.
  }
  apply (gradth _ _ egf efg).
Defined.

(* Recall that pathsspace' consists of pairs of points and a path
   between them. *)
Corollary isweqpr1pr1 (T : UU) :
  isweq (fun (a : pathsspace' T) => pr1 (pr1 a)).
Proof.
  intros.
  set (f := fun (a : pathsspace' T) => pr1 (pr1 a)).
  set (g := fun (t : T) => 
              tpair _ (dirprodpair t t) (idpath t) : pathsspace' T).
  assert (efg : forall t : T, f (g t) = t).
  { intros t. unfold f. unfold g. simpl. apply idpath. }
  assert (egf : forall a : _, g (f a) = a).
  { intros a. induction a as [xy e].
    induction xy as [x y]. simpl in e.
    induction e. unfold f. unfold g.
    apply idpath.
  }
  apply (gradth _ _ egf efg).
Defined.

Lemma hfibershomotftog {X Y : UU} (f g : X -> Y)
  (h : f ~ g) (y : Y) : hfiber f y -> hfiber g y .
Proof.
  intros X Y f g h y xe.
  induction xe as [x e].
  split with x.
  apply (!(h x) @ e).
Defined.

Lemma hfibershomotgtof {X Y : UU} (f g : X -> Y) 
  (h : f ~ g) (y : Y) : hfiber g y -> hfiber f y.
Proof.
  intros X Y f g h y xe.
  induction xe as [x e].
  split with x.
  apply (h x @ e).
Defined.

Theorem weqhfibershomot {X Y : UU} (f g : X -> Y) 
  (h : f ~ g) (y : Y) : weq (hfiber f y) (hfiber g y).
Proof.
  intros X Y f g h y.
  set (ff := hfibershomotftog f g h y).
  set (gg := hfibershomotgtof f g h y).

  split with ff.

  assert (effgg : forall xe : _, ff (gg xe) = xe).
  {
    intro xe.
    induction xe as [x e].
    simpl.
    assert (eee : ! h x @ h x @ e = maponpaths g (idpath x) @ e).
    { simpl.  induction e. induction (h x). apply idpath. }
    set (xe1 := hfiberpair g x (! h x @ h x @ e)).
    set (xe2 := hfiberpair g x e).
    apply (hfibertriangle2 g xe1 xe2 (idpath x) eee).
  }

  assert (eggff : forall xe : _, gg (ff xe) = xe).
  {
    intro xe.
    induction xe as [x e].
    simpl.
    assert (eee :  h x @ !h x @ e = maponpaths f (idpath x) @ e).
    { simpl.  induction e. induction (h x). apply idpath. }
    set (xe1 := hfiberpair f x (h x @ ! h x @ e)).
    set (xe2 := hfiberpair f x e).
    apply (hfibertriangle2 f xe1 xe2 (idpath x) eee).
  }

  apply (gradth _ _ eggff effgg).
Defined.

(** *** The 2-out-of-3 property of weak equivalences. 
    
    Theorems showing that if any two of three functions f, g, gf are
    weak equivalences then so is the third - the 2-out-of-3 property.
*)

Theorem twooutof3a {X Y Z : UU} (f : X -> Y) (g : Y -> Z)
  (isgf: isweq (g circ f)) (isg: isweq g) : isweq f.
Proof.
  intros.
  set (gw := weqpair g isg).
  set (gfw := weqpair (g circ f) isgf).
  set (invg := invmap gw).
  set (invgf := invmap gfw).

  set (invf := invgf circ g).

  assert (efinvf : forall y : Y, f (invf y) = y).
  {
    intro y.
    assert (int1 : g (f (invf y)) = g y).
    { unfold invf. apply (homotweqinvweq gfw (g y)). }
    apply (invmaponpathsweq gw _ _  int1). 
  }

  assert (einvff: forall x : X, invf (f x) = x).
  { intro. unfold invf. apply (homotinvweqweq gfw x). }

  apply (gradth f invf einvff efinvf).
Defined.

Corollary isweqcontrcontr {X Y : UU} (f : X -> Y) 
  (isx : iscontr X) (isy: iscontr Y): isweq f.
Proof.
  intros.
  set (py := fun (y : Y) => tt).
  apply (twooutof3a f py (isweqcontrtounit isx) (isweqcontrtounit isy)).
Defined.

Definition weqcontrcontr {X Y : UU} (isx : iscontr X) (isy: iscontr Y) :=
  weqpair _ (isweqcontrcontr (fun (x : X) => pr1 isy) isx isy). 

Theorem twooutof3b {X Y Z : UU} (f : X -> Y) (g : Y -> Z)
  (isf: isweq f) (isgf: isweq (g circ f)) : isweq g.
Proof.
  intros.
  set (wf := weqpair f isf).
  set (wgf := weqpair (g circ f) isgf).
  set (invf := invmap wf).
  set (invgf := invmap wgf).

  set (invg := f circ invgf).
 
  assert (eginvg : forall z : Z, g (invg z) = z).
  { intro. unfold invg. apply (homotweqinvweq wgf z). }

  assert (einvgg : forall y : Y, invg (g y) = y).
  { intro. unfold invg.

    assert (isinvf: isweq invf).
    { apply isweqinvmap. }
    assert (isinvgf: isweq invgf).
    { apply isweqinvmap. }

    assert (int1 : g y = (g circ f) (invf y)).
     apply (maponpaths g (! homotweqinvweq wf y)).

    assert (int2 : (g circ f) (invgf (g y)) = (g circ f) (invf y)).
    { 
      assert (int3: paths ((g circ f) (invgf (g y))) (g y)).
      { apply (homotweqinvweq wgf). }
      induction int1. 
      apply int3.
    }
   
    assert (int4: paths (invgf (g y)) (invf y)).
    { apply (invmaponpathsweq wgf). apply int2. }

    assert (int5: paths (invf (f (invgf (g y)))) (invgf (g y))).
    { apply (homotinvweqweq wf ). }

     assert (int6: paths (invf (f (invgf (g (y))))) (invf y)). 
    { induction int4. apply int5. }
   
     apply (invmaponpathsweq ( weqpair invf isinvf ) ).
     simpl.
     apply int6.
  }

  apply (gradth g invg einvgg eginvg).
Defined.

Lemma isweql3 {X Y : UU} (f : X -> Y) (g : Y -> X)
  (egf: forall x : X, g (f x) = x): isweq f -> isweq g.
Proof.
  intros X Y f g egf w.
  assert (int1 : isweq (g circ f)).
  {
    apply (isweqhomot (idfun X) (g circ f) (fun (x : X) => ! (egf x))).
    apply idisweq.
  }
  apply (twooutof3b f g w int1).
Defined.

Theorem twooutof3c {X Y Z : UU} (f : X -> Y) (g : Y -> Z)
  (isf: isweq f) (isg: isweq g) : isweq (g circ f).
Proof.
  intros.
  set (wf := weqpair f isf).
  set (wg := weqpair g isg).
  set (invf := invmap wf).
  set (invg := invmap wg).

  set (gf := g circ f).
  set (invgf := invf circ invg).

  assert (egfinvgf : forall x : X, invgf (gf x) = x).
  {
    intros x.
    assert (int1 : invf (invg (g (f x))) = invf (f x)).
    { apply (maponpaths invf (homotinvweqweq wg (f x))). }
    assert (int2 : invf (f x) = x).
    { apply (homotinvweqweq wf x). }
    induction int1.
    apply int2.
  }

  assert (einvgfgf : forall z : Z, gf (invgf z) = z).
  {
    intros z.
    assert (int1 : g (f (invgf z)) = g (invg z)).
    { 
      unfold invgf.
      apply (maponpaths g (homotweqinvweq wf (invg z))).
    }
    assert (int2 : g (invg z) = z).
    { apply (homotweqinvweq wg z). }
    induction int1.
    apply int2.
  }

  apply (gradth gf invgf egfinvgf einvgfgf).
Defined.

Definition weqcomp {X Y Z : UU} (w1 : weq X Y) (w2 : weq Y Z) : (weq X Z) :=
  weqpair (fun (x : X) => w2 (w1 x)) (twooutof3c w1 w2 (pr2 w1) (pr2 w2)). 


(** *** The 2-out-of-6 (two-out-of-six) property of weak equivalences. *)


Theorem twooutofsixu {X Y Z K : UU}{u : X -> Y}{v : Y -> Z}{w : Z -> K}
        (isuv : isweq ( funcomp u v ))(isvw : isweq (funcomp v w)) : isweq u.
Proof.
  intros .
       
  set ( invuv := invmap ( weqpair _ isuv ) ) .
  set ( pu := funcomp v invuv ) .
  set (hupu := homotinvweqweq ( weqpair _ isuv ) : homot ( funcomp u pu ) ( idfun X ) ) . 
                                      
  set ( invvw := invmap ( weqpair _ isvw ) ) .
  set ( pv := funcomp w invvw ) .
  set (hvpv := homotinvweqweq ( weqpair _ isvw ) : homot ( funcomp v pv ) ( idfun Y ) ) . 

  set ( h0 := funhomot v ( homotweqinvweq ( weqpair _ isuv ) ) ) .
  set ( h1 := funhomot ( funcomp pu u ) ( invhomot hvpv ) ) .
  set ( h2 := homotfun h0 pv ) .

  set ( hpuu := homotcomp ( homotcomp h1 h2 ) hvpv ) .

  exact ( gradth u pu hupu hpuu ) . 
Defined.

Theorem twooutofsixv {X Y Z K : UU}{u : X -> Y}{v : Y -> Z}{w : Z -> K}
        (isuv : isweq ( funcomp u v ))(isvw : isweq (funcomp v w)) : isweq v.
Proof.
  intros . exact ( twooutof3b _ _ ( twooutofsixu isuv isvw ) isuv ) .
Defined.

Theorem twooutofsixw {X Y Z K : UU}{u : X -> Y}{v : Y -> Z}{w : Z -> K}
        (isuv : isweq ( funcomp u v ))(isvw : isweq (funcomp v w)) : isweq w.
Proof.
  intros . exact ( twooutof3b _ _ ( twooutofsixv isuv isvw ) isvw ) .
Defined.

(** *** Associativity of [ total2 ]  *)

Lemma total2asstor { X : UU } ( P : X -> UU ) ( Q : total2 P -> UU ) : total2 Q ->  total2 ( fun x : X => total2 ( fun p : P x => Q ( tpair P x p ) ) ) .
Proof. intros X P Q xpq .  induction xpq as [ xp q ] . induction xp as [ x p ] . split with x . split with p . assumption . Defined .

Lemma total2asstol { X : UU } ( P : X -> UU ) ( Q : total2 P -> UU ) : total2 ( fun x : X => total2 ( fun p : P x => Q ( tpair P x p ) ) ) -> total2 Q .
Proof. intros X P Q xpq .  induction xpq as [ x pq ] . induction pq as [ p q ] . split with ( tpair P x p ) . assumption . Defined .


Theorem weqtotal2asstor { X : UU } ( P : X -> UU ) ( Q : total2 P -> UU ) : weq ( total2 Q ) ( total2 ( fun x : X => total2 ( fun p : P x => Q ( tpair P x p ) ) ) ).
Proof. intros . set ( f := total2asstor P Q ) . set ( g:= total2asstol P Q ) .  split with f .
assert ( egf : forall xpq : _ , paths ( g ( f xpq ) ) xpq ) . intro . induction xpq as [ xp q ] . induction xp as [ x p ] . apply idpath . 
assert ( efg : forall xpq : _ , paths ( f ( g xpq ) ) xpq ) . intro . induction xpq as [ x pq ] . induction pq as [ p q ] . apply idpath .
apply ( gradth _ _ egf efg ) . Defined.

Definition weqtotal2asstol { X : UU } ( P : X -> UU ) ( Q : total2 P -> UU ) : weq ( total2 ( fun x : X => total2 ( fun p : P x => Q ( tpair P x p ) ) ) ) ( total2 Q ) := invweq ( weqtotal2asstor P Q ) .



(** *** Associativity and commutativity of [ dirprod ] *) 

Definition weqdirprodasstor ( X Y Z : UU ) : weq ( dirprod ( dirprod X Y ) Z ) ( dirprod X ( dirprod Y Z ) ) .
Proof . intros . apply weqtotal2asstor . Defined . 

Definition weqdirprodasstol ( X Y Z : UU ) : weq  ( dirprod X ( dirprod Y Z ) ) ( dirprod ( dirprod X Y ) Z ) := invweq ( weqdirprodasstor X Y Z ) .

Definition weqdirprodcomm ( X Y : UU ) : weq ( dirprod X Y ) ( dirprod Y X ) .
Proof. intros . set ( f := fun xy : dirprod X Y => dirprodpair ( pr2 xy ) ( pr1 xy ) ) . set ( g := fun yx : dirprod Y X => dirprodpair ( pr2 yx ) ( pr1 yx ) ) .
assert ( egf : forall xy : _ , paths ( g ( f xy ) ) xy ) . intro . induction xy . apply idpath .
assert ( efg : forall yx : _ , paths ( f ( g yx ) ) yx ) . intro . induction yx . apply idpath .
split with f . apply ( gradth _ _ egf  efg ) . Defined . 
 





(** *** Coproducts and direct products *)


Definition rdistrtocoprod ( X Y Z : UU ): dirprod X (coprod Y Z) -> coprod (dirprod X Y) (dirprod X Z).
Proof. intros X Y Z X0. induction X0 as [ t x ].  induction x as [ y | z ] .   apply (ii1  (dirprodpair  t y)). apply (ii2  (dirprodpair  t z)). Defined.


Definition rdistrtoprod (X Y Z:UU): coprod (dirprod X Y) (dirprod X Z) ->  dirprod X (coprod Y Z).
Proof. intros X Y Z X0. induction X0 as [ d | d ].  induction d as [ t x ]. apply (dirprodpair  t (ii1  x)). induction d as [ t x ]. apply (dirprodpair  t (ii2  x)). Defined. 


Theorem isweqrdistrtoprod (X Y Z:UU): isweq (rdistrtoprod X Y Z).
Proof. intros. set (f:= rdistrtoprod X Y Z). set (g:= rdistrtocoprod X Y Z). 
assert (egf: forall a:_, paths (g (f a)) a).  intro. induction a as [ d | d ] . induction d. apply idpath. induction d. apply idpath. 
assert (efg: forall a:_, paths (f (g a)) a). intro. induction a as [ t x ]. induction x.  apply idpath. apply idpath.
apply (gradth  f g egf efg). Defined.

Definition weqrdistrtoprod (X Y Z: UU):= weqpair  _ (isweqrdistrtoprod X Y Z).

Corollary isweqrdistrtocoprod (X Y Z:UU): isweq (rdistrtocoprod X Y Z).
Proof. intros. apply (isweqinvmap ( weqrdistrtoprod X Y Z  ) ) . Defined.

Definition weqrdistrtocoprod (X Y Z: UU):= weqpair  _ (isweqrdistrtocoprod X Y Z).
 


(** *** Total space of a family over a coproduct *)


Definition fromtotal2overcoprod { X Y : UU } ( P : coprod X Y -> UU ) ( xyp : total2 P ) : coprod ( total2 ( fun x : X => P ( ii1 x ) ) ) ( total2 ( fun y : Y => P ( ii2 y ) ) ) .
Proof. intros . set ( PX :=  fun x : X => P ( ii1 x ) ) . set ( PY :=  fun y : Y => P ( ii2 y ) ) . induction xyp as [ xy p ] . induction xy as [ x | y ] . apply (  ii1 ( tpair PX x p ) ) .   apply ( ii2 ( tpair PY y p ) ) . Defined .

Definition tototal2overcoprod { X Y : UU } ( P : coprod X Y -> UU ) ( xpyp :  coprod ( total2 ( fun x : X => P ( ii1 x ) ) ) ( total2 ( fun y : Y => P ( ii2 y ) ) ) ) : total2 P .
Proof . intros . induction xpyp as [ xp | yp ] . induction xp as [ x p ] . apply ( tpair P ( ii1 x ) p ) .   induction yp as [ y p ] . apply ( tpair P ( ii2 y ) p ) . Defined . 
 
Theorem weqtotal2overcoprod { X Y : UU } ( P : coprod X Y -> UU ) : weq ( total2 P ) ( coprod ( total2 ( fun x : X => P ( ii1 x ) ) ) ( total2 ( fun y : Y => P ( ii2 y ) ) ) ) .
Proof. intros .  set ( f := fromtotal2overcoprod P ) . set ( g := tototal2overcoprod P ) . split with f . 
assert ( egf : forall a : _ , paths ( g ( f a ) ) a ) . intro a . induction a as [ xy p ] . induction xy as [ x | y ] . simpl . apply idpath . simpl .  apply idpath .     
assert ( efg : forall a : _ , paths ( f ( g a ) ) a ) . intro a . induction a as [ xp | yp ] . induction xp as [ x p ] . simpl . apply idpath .  induction yp as [ y p ] . apply idpath .
apply ( gradth _ _ egf efg ) . Defined . 



(** *** Weak equivalences and pairwise direct products *)


Theorem isweqdirprodf { X Y X' Y' : UU } ( w : weq X Y )( w' : weq X' Y' ) : isweq (dirprodf w w' ).
Proof. intros. set ( f := dirprodf w w' ) . set ( g := dirprodf ( invweq w ) ( invweq w' ) ) . 
assert ( egf : forall a : _ , paths ( g ( f a ) ) a ) . intro a . induction a as [ x x' ] .  simpl .   apply pathsdirprod . apply ( homotinvweqweq w x ) .  apply ( homotinvweqweq w' x' ) . 
assert ( efg : forall a : _ , paths ( f ( g a ) ) a ) . intro a . induction a as [ x x' ] .  simpl .   apply pathsdirprod . apply ( homotweqinvweq w x ) .  apply ( homotweqinvweq w' x' ) .
apply ( gradth _ _ egf efg ) . Defined .   

Definition weqdirprodf { X Y X' Y' : UU } ( w : weq X Y ) ( w' : weq X' Y' ) := weqpair _ ( isweqdirprodf w w' ) .

Definition weqtodirprodwithunit (X:UU): weq X (dirprod X unit).
Proof. intros. set (f:=fun x:X => dirprodpair x tt). split with f.  set (g:= fun xu:dirprod X unit => pr1  xu). 
assert (egf: forall x:X, paths (g (f x)) x). intro. apply idpath.
assert (efg: forall xu:_, paths (f (g xu)) xu). intro. induction xu as  [ t x ]. induction x. apply idpath.    
apply (gradth  f g egf efg). Defined.




(** *** Basics on pairwise coproducts (disjoint unions)  *)



(** In the current version [ coprod ] is a notation, introduced in uuu.v for [ sum ] of types which is defined in Coq.Init *)



Definition sumofmaps {X Y Z:UU}(fx: X -> Z)(fy: Y -> Z): (coprod X Y) -> Z := fun xy:_ => match xy with ii1 x => fx x | ii2 y => fy y end.


Definition boolascoprod: weq (coprod unit unit) bool.
Proof. set (f:= fun xx: coprod unit unit => match xx with ii1 t => true | ii2 t => false end). split with f. 
set (g:= fun t:bool => match t with true => ii1  tt | false => ii2  tt end). 
assert (egf: forall xx:_, paths (g (f xx)) xx). intro xx .  induction xx as [ u | u ] . induction u. apply idpath. induction u. apply idpath. 
assert (efg: forall t:_, paths (f (g t)) t). induction t. apply idpath. apply idpath. 
apply (gradth  f g egf efg). Defined.  


Definition coprodasstor (X Y Z:UU): coprod (coprod X Y) Z -> coprod X (coprod Y Z).
Proof. intros X Y Z X0. induction X0 as [ c | z ] .  induction c as [ x | y ] .  apply (ii1  x). apply (ii2  (ii1  y)). apply (ii2  (ii2  z)). Defined.

Definition coprodasstol (X Y Z: UU): coprod X (coprod Y Z) -> coprod (coprod X Y) Z.
Proof. intros X Y Z X0. induction X0 as [ x | c ] .  apply (ii1  (ii1  x)). induction c as [ y | z ] .   apply (ii1  (ii2  y)). apply (ii2  z). Defined.

Theorem isweqcoprodasstor (X Y Z:UU): isweq (coprodasstor X Y Z).
Proof. intros. set (f:= coprodasstor X Y Z). set (g:= coprodasstol X Y Z).
assert (egf: forall xyz:_, paths (g (f xyz)) xyz). intro xyz. induction xyz as [ c | z ] .  induction c. apply idpath. apply idpath. apply idpath. 
assert (efg: forall xyz:_, paths (f (g xyz)) xyz). intro xyz.  induction xyz as [ x | c ] .  apply idpath.  induction c. apply idpath. apply idpath.
apply (gradth  f g egf efg). Defined. 

Definition weqcoprodasstor ( X Y Z : UU ) := weqpair _ ( isweqcoprodasstor X Y Z ) .

Corollary isweqcoprodasstol (X Y Z:UU): isweq (coprodasstol X Y Z).
Proof. intros. apply (isweqinvmap ( weqcoprodasstor X Y Z)  ). Defined.

Definition weqcoprodasstol (X Y Z:UU):= weqpair  _ (isweqcoprodasstol X Y Z).

Definition coprodcomm (X Y:UU): coprod X Y -> coprod Y X := fun xy:_ => match xy with ii1 x => ii2  x | ii2 y => ii1  y end. 

Theorem isweqcoprodcomm (X Y:UU): isweq (coprodcomm X Y).
Proof. intros. set (f:= coprodcomm X Y). set (g:= coprodcomm Y X).
assert (egf: forall xy:_, paths (g (f xy)) xy). intro. induction xy. apply idpath. apply idpath.
assert (efg: forall yx:_, paths (f (g yx)) yx). intro. induction yx. apply idpath. apply idpath.
apply (gradth  f g egf efg). Defined. 

Definition weqcoprodcomm (X Y:UU):= weqpair  _ (isweqcoprodcomm X Y). 

Theorem isweqii1withneg  (X : UU) { Y : UU } (nf:Y -> empty): isweq (@ii1 X Y).
Proof. intros. set (f:= @ii1 X Y). set (g:= fun xy:coprod X Y => match xy with ii1 x => x | ii2 y => fromempty (nf y) end).  
assert (egf: forall x:X, paths (g (f x)) x). intro. apply idpath. 
assert (efg: forall xy: coprod X Y, paths (f (g xy)) xy). intro. induction xy as [ x | y ] . apply idpath. apply (fromempty (nf y)).  
apply (gradth  f g egf efg). Defined.  

Definition weqii1withneg ( X : UU ) { Y : UU } ( nf : neg Y ) := weqpair _ ( isweqii1withneg X nf ) .

Theorem isweqii2withneg  { X  : UU } ( Y : UU ) (nf : X -> empty): isweq (@ii2 X Y).
Proof. intros. set (f:= @ii2 X Y). set (g:= fun xy:coprod X Y => match xy with ii1 x => fromempty (nf x) | ii2 y => y end).  
assert (egf: forall y : Y, paths (g (f y)) y). intro. apply idpath. 
assert (efg: forall xy: coprod X Y, paths (f (g xy)) xy). intro. induction xy as [ x | y ] . apply (fromempty (nf x)).  apply idpath. 
apply (gradth  f g egf efg). Defined.  

Definition weqii2withneg { X : UU } ( Y : UU ) ( nf : neg X ) := weqpair _ ( isweqii2withneg Y nf ) .



Definition coprodf { X Y X' Y' : UU } (f: X -> X')(g: Y-> Y'): coprod X Y -> coprod X' Y' := fun xy: coprod X Y =>
match xy with
ii1 x => ii1  (f x)|
ii2 y => ii2  (g y)
end. 


Definition homotcoprodfcomp { X X' Y Y' Z Z' : UU } ( f : X -> Y ) ( f' : X' -> Y' ) ( g : Y -> Z ) ( g' : Y' -> Z' ) : homot ( funcomp ( coprodf f f' ) ( coprodf g g' ) ) ( coprodf ( funcomp f g ) ( funcomp f' g' ) ) .
Proof. intros . intro xx' . induction xx' as [ x | x' ] . apply idpath . apply idpath . Defined .  


Definition homotcoprodfhomot { X X' Y Y' } ( f g : X -> Y ) ( f' g' : X' -> Y' ) ( h : homot f g ) ( h' : homot f' g' ) : homot ( coprodf f f') ( coprodf g g') := fun xx' : _ => match xx' with ( ii1 x ) => maponpaths ( @ii1 _ _ ) ( h x ) | ( ii2 x' ) => maponpaths ( @ii2 _ _ ) ( h' x' ) end  .


Theorem isweqcoprodf { X Y X' Y' : UU } ( w : weq X X' )( w' : weq Y Y' ) : isweq (coprodf w w' ).
Proof. intros. set (finv:= invmap w ). set (ginv:= invmap w' ). set (ff:=coprodf w w' ). set (gg:=coprodf   finv ginv). 
assert (egf: forall xy: coprod X Y, paths (gg (ff xy)) xy). intro. induction xy as [ x | y ] . simpl. apply (maponpaths (@ii1 X Y)  (homotinvweqweq w x)).     apply (maponpaths (@ii2 X Y)  (homotinvweqweq w' y)).
assert (efg: forall xy': coprod X' Y', paths (ff (gg xy')) xy'). intro. induction xy' as [ x | y ] . simpl.  apply (maponpaths (@ii1 X' Y')  (homotweqinvweq w x)).     apply (maponpaths (@ii2 X' Y')  (homotweqinvweq w' y)). 
apply (gradth  ff gg egf efg). Defined. 


Definition weqcoprodf { X Y X' Y' : UU } (w1: weq X Y)(w2: weq X' Y') : weq (coprod X X') (coprod Y Y') := weqpair _ ( isweqcoprodf w1 w2 ) .


Lemma negpathsii1ii2 { X Y : UU } (x:X)(y:Y): neg (paths (ii1  x) (ii2  y)).
Proof. intros. unfold neg. intro X0. set (dist:= fun xy: coprod X Y => match xy with ii1 x => unit | ii2 y => empty end). apply (transportf dist  X0 tt). Defined.

Lemma negpathsii2ii1 { X Y : UU } (x:X)(y:Y): neg (paths (ii2  y) (ii1  x)).
Proof. intros. unfold neg. intro X0. set (dist:= fun xy: coprod X Y => match xy with ii1 x => empty | ii2 y => unit end). apply (transportf dist  X0 tt). Defined.







(** *** Fibrations with only one non-empty fiber. 

Theorem saying that if a fibration has only one non-empty fiber then the total space is weakly equivalent to this fiber. *)



Theorem onefiber { X : UU } (P:X -> UU)(x:X)(c: forall x':X, coprod (paths x x') (P x' -> empty)) : isweq (fun p: P x => tpair P x p).
Proof. intros.  

set (f:= fun p: P x => tpair _ x p). 

set (cx := c x). 
set (cnew:=  fun x':X  =>
match cx with 
ii1 x0 =>
match c x' with 
ii1 ee => ii1  (pathscomp0   (pathsinv0  x0) ee)|
ii2 phi => ii2  phi
end |
ii2 phi => c x'
end).

set (g:= fun pp: total2 P => 
match (cnew (pr1  pp)) with
ii1 e => transportb P  e (pr2  pp) |
ii2 phi =>  fromempty (phi (pr2  pp))
end).


assert (efg: forall pp: total2 P, paths (f (g pp)) pp).  intro. induction pp as [ t x0 ]. set (cnewt:= cnew t).  unfold g. unfold f. simpl. change (cnew t) with cnewt. induction cnewt as [ x1 | y ].  apply (pathsinv0 (pr1  (pr2  (constr1 P (pathsinv0 x1))) x0)). induction (y x0). 

 
set (cnewx:= cnew x). 
assert (e1: paths (cnew x) cnewx). apply idpath. 
unfold cnew in cnewx. change (c x) with cx in cnewx.  
induction cx as [ x0 | e0 ].  
assert (e: paths (cnewx) (ii1  (idpath x))).  apply (maponpaths (@ii1 (paths x x) (P x -> empty))  (pathsinv0l x0)). 




assert (egf: forall p: P x, paths (g (f p)) p).  intro. simpl in g. unfold g.  unfold f.   simpl.   

set (ff:= fun cc:coprod (paths x x) (P x -> empty) => 
match cc with
     | ii1 e0 => transportb P e0 p
     | ii2 phi => fromempty  (phi p)
     end).
assert (ee: paths (ff (cnewx)) (ff (@ii1 (paths x x) (P x -> empty) (idpath x)))).  apply (maponpaths ff  e). 
assert (eee: paths  (ff (@ii1 (paths x x) (P x -> empty) (idpath x))) p). apply idpath.  fold (ff (cnew x)). 
assert (e2: paths (ff (cnew x)) (ff cnewx)). apply (maponpaths ff  e1). 
apply (pathscomp0   (pathscomp0   e2 ee) eee).
apply (gradth  f g egf efg).

unfold isweq.  intro y0. induction (e0 (g y0)). Defined.


(* Below is another proof of onefiber that does not use iterated match. *)


Theorem onefiber' { X : UU } ( P : X -> UU ) ( x : X )
      ( c : forall x' : X , coprod ( x = x' ) ( P x' -> empty ) ) :
  isweq ( fun p : P x => tpair P x p ) . 
Proof.
  intros .

  set ( f := fun p => tpair _ x p ) .   

  set ( Q1 := hfiber ( @pr1 _ P ) x ) .
  set ( Q2 := total2 ( fun xp : total2 P => ( P ( pr1 xp ) -> empty ) ) ) .
  set ( toQ1Q2 := fun xp : total2 P => fun eorem : coprod ( x = ( pr1 xp ) )
                                                          ( P ( pr1 xp ) -> empty ) =>
                                         @sumofmaps _ _ ( coprod Q1 Q2 )
                                                    ( fun e => ii1 ( tpair _ xp ( ! e ) ) )
                                                    ( fun em => ii2 ( tpair _ xp em ) ) eorem ) .
  set ( ctot := fun xp : total2 P => toQ1Q2 xp ( c ( pr1 xp ) ) ) . 

  set ( int1 := fun q1 : Q1 => transportf P  ( pr2 q1 ) ( pr2  ( pr1 q1 ) ) ) . 
  set ( int2 := fun q2 : Q2 => @fromempty ( P x ) ( ( pr2 q2 ) ( pr2 ( pr1 q2 ) ) ) ) .
  set ( cint := fun xp : total2 P => ( sumofmaps int1  int2 ) ( ctot xp ) ) .

  apply ( @twooutofsixu _ _ _ _ f cint f ) . 


  unfold funcomp . unfold cint . unfold f . unfold ctot . unfold toQ1Q2 . simpl .
  induction ( c x ) as [ e | em ] .

  unfold int1 . simpl . apply isweqtransportf .

  simpl . unfold isweq .  intro p . induction ( em p ) . 


  assert ( efg : forall xp : total2 P , f ( cint xp ) = xp ) . 

  set ( dpr := @sumofmaps Q1 Q2 _ pr1 pr1 ) .
  
  assert ( hint : forall xp : total2 P , dpr ( ctot xp ) = xp ) .  intro xp .
  unfold ctot . unfold toQ1Q2. unfold dpr .  simpl .
  induction ( c ( pr1 xp ) ) . apply idpath . apply idpath . 
  
   intro xp .

  set ( ctotxp := ctot xp ) . assert ( e : ctotxp = ctot xp ) . apply idpath .

  unfold cint . change ( ctot xp ) with ctotxp .

  induction ctotxp as [ q1 | q2 ] . unfold sumofmaps .  simpl . 

  assert ( e1 : pr1 q1 = xp ) . set  ( eint := maponpaths ( sumofmaps pr1 pr1 ) e ) .
  simpl in eint. exact ( eint @ ( hint xp ) ) . 

  assert ( e2 : tpair P x ( int1 q1 ) = pr1 q1 ) .  unfold int1 . induction ( pr2 q1 ) .
  unfold transportf .  simpl . unfold idfun . apply pathsinv0 . apply tppr . 

  exact ( e2 @ e1 ) .

  assert ( e1 : pr1 q2 = xp ) .  set  ( eint := maponpaths ( sumofmaps pr1 pr1 ) e ) .
  simpl in eint. exact ( eint @ ( hint xp ) ) . 

  induction ( ( pr2 q2 ) ( transportb P ( maponpaths pr1 e1 ) ( pr2 xp ) ) ) .

  apply ( isweqhomot _ _ ( invhomot efg ) ) . exact ( idisweq _ ) . 

Defined.





(** *** Pairwise coproducts as dependent sums of families over [ bool ] *)


Fixpoint coprodtobool { X Y : UU } ( xy : coprod X Y ) : bool :=
match xy with
ii1 x => true|
ii2 y => false
end.
 

Definition boolsumfun (X Y:UU) : bool -> UU := fun t:_ => 
match t with
true => X|
false => Y
end.

Definition coprodtoboolsum ( X Y : UU ) : coprod X Y -> total2 (boolsumfun X Y) := fun xy : _ =>
match xy with
ii1 x => tpair (boolsumfun X Y) true x|
ii2 y => tpair (boolsumfun X Y) false y
end .


Definition boolsumtocoprod (X Y:UU): (total2 (boolsumfun X Y)) -> coprod X Y := (fun xy:_ =>
match xy with 
tpair _ true x => ii1  x|
tpair _ false y => ii2  y
end).



Theorem isweqcoprodtoboolsum (X Y:UU): isweq (coprodtoboolsum X Y).
Proof. intros. set (f:= coprodtoboolsum X Y). set (g:= boolsumtocoprod X Y). 
assert (egf: forall xy: coprod X Y , paths (g (f xy)) xy). induction xy. apply idpath. apply idpath. 
assert (efg: forall xy: total2 (boolsumfun X Y), paths (f (g xy)) xy). intro. induction xy as [ t x ]. induction t.  apply idpath. apply idpath. apply (gradth  f g egf efg). Defined.

Definition weqcoprodtoboolsum ( X Y : UU ) := weqpair _ ( isweqcoprodtoboolsum X Y ) .

Corollary isweqboolsumtocoprod (X Y:UU): isweq (boolsumtocoprod X Y ).
Proof. intros. apply (isweqinvmap ( weqcoprodtoboolsum X Y ) ) . Defined.

Definition weqboolsumtocoprod ( X Y : UU ) := weqpair _ ( isweqboolsumtocoprod X Y ) .








(** *** Splitting of [ X ] into a coproduct defined by a function [ X -> coprod Y Z ] *)


Definition weqcoprodsplit { X Y Z : UU } ( f : X -> coprod Y Z ) : weq  X  ( coprod ( total2 ( fun y : Y => hfiber f ( ii1 y ) ) ) ( total2 ( fun z : Z => hfiber f ( ii2 z ) ) ) ) .
Proof . intros . set ( w1 := weqtococonusf f ) .  set ( w2 := weqtotal2overcoprod ( fun yz : coprod Y Z => hfiber f yz ) ) . apply ( weqcomp w1 w2 ) .  Defined . 



(** *** Some properties of [ bool ] *)

Definition boolchoice ( x : bool ) : coprod ( paths x true ) ( paths x false ) .
Proof. intro . induction x . apply ( ii1 ( idpath _ ) ) .  apply ( ii2 ( idpath _ ) ) . Defined . 

Definition curry :  bool -> UU := fun x : bool =>
match x  with
false => empty|
true => unit
end.


Theorem nopathstruetofalse: paths true false -> empty.
Proof. intro X.  apply (transportf curry  X tt).  Defined.

Corollary nopathsfalsetotrue: paths false true -> empty.
Proof. intro X. apply (transportb curry  X tt). Defined. 

Definition truetonegfalse ( x : bool ) : paths x true -> neg ( paths x false ) .
Proof . intros x e . rewrite e . unfold neg . apply nopathstruetofalse . Defined . 

Definition falsetonegtrue ( x : bool ) : paths x false -> neg ( paths x true ) .
Proof . intros x e . rewrite e . unfold neg . apply nopathsfalsetotrue . Defined .  

Definition negtruetofalse (x : bool ) : neg ( paths x true ) -> paths x false .
Proof. intros x ne. induction (boolchoice x) as [t | f]. induction (ne t). apply f. Defined. 

Definition negfalsetotrue ( x : bool ) : neg ( paths x false ) -> paths x true . 
Proof. intros x ne . induction (boolchoice x) as [t | f].  apply t . induction (ne f) . Defined. 











(** ** Basics about fibration sequences. *)



(** *** Fibrations sequences and their first "left shifts". 

The group of constructions related to fibration sequences forms one of the most important computational toolboxes of homotopy theory .   

Given a pair of functions [ ( f : X -> Y ) ( g : Y -> Z ) ] and a point [ z : Z ] , a structure of the complex on such a triple is a homotopy from the composition [ funcomp f g ] to the constant function [ X -> Z ] corresponding to [ z ] i.e. a term [ ez : forall x:X, paths ( g ( f x ) ) z ]. Specifing such a structure is essentially equivalent to specifing a structure of the form [ ezmap : X -> hfiber g z ]. The mapping in one direction is given in the definition of [ ezmap ] below. The mapping in another is given by [ f := fun x : X => pr1 ( ezmap x ) ] and [ ez := fun x : X => pr2 ( ezmap x ) ].

A complex is called a fibration sequence if [ ezmap ] is a weak equivalence. Correspondingly, the structure of a fibration sequence on [ f g z ] is a pair [ ( ez , is ) ] where [ is : isweq ( ezmap f g z ez ) ]. For a fibration sequence [ f g z fs ]  where [ fs : fibseqstr f g z ] and any [ y : Y ] there is defined a function [ diff1 : paths ( g y ) z -> X ] and a structure of the fibration sequence [ fibseqdiff1 ] on the triple [ diff1 g y ]. This new fibration sequence is called the derived fibration sequence of the original one.  

The first function of the second derived of [ f g z fs ] corresponding to [ ( y : Y ) ( x : X ) ]  is of the form [ paths ( f x ) y -> paths ( g y ) z ] and it is homotopic to the function defined by [ e => pathscomp0 ( maponpaths g  ( pathsinv0 e) ) ( ez x ) ]. The first function of the third derived of [ f g z fs ] corresponding to [ ( y : Y ) ( x : X ) ( e : paths ( g y ) z ) ] is of the form [ paths ( diff1 e ) x -> paths ( f x ) y ]. Therefore, the third derived of a sequence based on [ X Y Z ] is based entirely on paths types of [ X ], [ Y ] and [ Z ]. When this construction is applied to types of finite h-level (see below) and combined with the fact that the h-level of a path type is strictly lower than the h-level of the ambient type it leads to the possibility of building proofs about types by induction on h-level.  

There are three important special cases in which fibration sequences arise:

( pr1 - case ) The fibration sequence [ fibseqpr1 P z ] defined by family [ P : Z -> UU ] and a term [ z : Z ]. It is based on the sequence of functions [ ( tpair P z : P z -> total2 P ) ( pr1 : total2 P -> Z ) ]. The corresponding [ ezmap ] is defined by an obvious rule and the fact that it is a weak equivalence is proved in [ isweqfibertohfiber ].

( g - case ) The fibration sequence [ fibseqg g z ]  defined by a function [ g : Y -> Z ] and a term [ z : Z ]. It is based on the sequence of functions [ ( hfiberpr1 : hfiber g z -> Y ) ( g : Y -> Z ) ] and the corresponding [ ezmap ] is the function which takes a term [ ye : hfiber ] to [ hfiberpair g ( pr1 ye ) ( pr2 ye ) ]. If we had eta-concersion for the depndent sums it would be the identiry function. Since we do not have this conversion in Coq this function is only homotopic to the identity function by [ tppr ] which is sufficient to ensure that it is a weak equivalence. The first derived of [ fibseqg g z ] corresponding to [ y : Y ] coincides with [ fibseqpr1 ( fun y' : Y  => paths ( g y' ) z ) y ].

( hf -case ) The fibration sequence of homotopy fibers defined for any pair of functions [ ( f : X -> Y ) ( g : Y -> Z ) ] and any terms [ ( z : Z ) ( ye : hfiber g z ) ]. It is based on functions [ hfiberftogf : hfiber f ( pr1 ye ) -> hfiber ( funcomp f g ) z ] and [ hfibergftog : hfiber ( funcomp f g ) z -> hfiber g z ] which are defined below.    


*)


(** The structure of a complex structure on a composable pair of functions [ ( f : X -> Y ) ( g : Y -> Z ) ] relative to a term [ z : Z ]. *) 

Definition complxstr  { X Y Z : UU } (f:X -> Y) (g:Y->Z) ( z : Z ) := forall x:X, paths (g (f x)) z .

 

(** The structure of a fibration sequence on a complex. *)

Definition ezmap { X Y Z : UU } (f:X -> Y) (g:Y->Z) ( z : Z ) (ez : complxstr f g z ) : X -> hfiber  g z :=  fun x:X => hfiberpair  g (f x) (ez x).

Definition isfibseq { X Y Z : UU } (f:X -> Y) (g:Y->Z) ( z : Z ) (ez : complxstr f g z ) := isweq (ezmap f g z ez). 

Definition fibseqstr { X Y Z : UU } (f:X -> Y) (g:Y->Z) ( z : Z ) := total2 ( fun ez : complxstr f g z => isfibseq f g z ez ) .
Definition fibseqstrpair { X Y Z : UU } (f:X -> Y) (g:Y->Z) ( z : Z ) := tpair ( fun ez : complxstr f g z => isfibseq f g z ez ) .
Definition fibseqstrtocomplxstr  { X Y Z : UU } (f:X -> Y) (g:Y->Z) ( z : Z ) : fibseqstr f g z -> complxstr f g z := @pr1 _  ( fun ez : complxstr f g z => isfibseq f g z ez ) .
Coercion fibseqstrtocomplxstr : fibseqstr >-> complxstr . 

Definition ezweq { X Y Z : UU } (f:X -> Y) (g:Y->Z) ( z : Z ) ( fs : fibseqstr f g z ) : weq X ( hfiber g z ) := weqpair _ ( pr2 fs ) . 



(** Construction of the derived fibration sequence. *)


Definition d1 { X Y Z : UU } ( f : X -> Y ) ( g : Y -> Z ) ( z : Z ) ( fs : fibseqstr f g z ) ( y : Y ) : paths ( g y ) z ->  X := fun e : _ =>  invmap ( ezweq f g z fs ) ( hfiberpair g y e ) .

Definition ezmap1 { X Y Z : UU } ( f : X -> Y ) ( g : Y -> Z ) ( z : Z ) ( fs : fibseqstr f g z ) ( y : Y ) ( e : paths ( g y ) z ) :  hfiber f y  .
Proof . intros . split with ( d1 f g z fs y e ) . unfold d1 . change ( f ( invmap (ezweq f g z fs) (hfiberpair g y e) ) ) with ( hfiberpr1 _ _ ( ezweq f g z fs ( invmap (ezweq f g z fs) (hfiberpair g y e) ) ) )  . apply ( maponpaths ( hfiberpr1 g z ) ( homotweqinvweq ( ezweq f g z fs ) (hfiberpair g y e) ) ) .  Defined .      

Definition invezmap1 { X Y Z : UU } ( f : X -> Y ) ( g : Y -> Z ) ( z : Z ) ( ez : complxstr f g z ) ( y : Y ) : hfiber  f y -> paths (g y) z :=  
fun xe: hfiber  f y =>
match xe with
tpair _ x e => pathscomp0 (maponpaths g  ( pathsinv0 e ) ) ( ez x )
end.

Theorem isweqezmap1 { X Y Z : UU } ( f : X -> Y ) ( g : Y -> Z ) ( z : Z ) ( fs : fibseqstr f g z ) ( y : Y ) : isweq ( ezmap1 f g z fs y ) .
Proof . intros . set ( ff := ezmap1 f g z fs y ) . set ( gg := invezmap1 f g z ( pr1 fs ) y ) . 
assert ( egf : forall e : _ , paths ( gg ( ff e ) ) e ) . intro .  simpl . apply ( hfibertriangle1inv0 g (homotweqinvweq (ezweq f g z fs) (hfiberpair g y e)) ) . 
assert ( efg : forall xe : _ , paths ( ff ( gg xe ) ) xe ) . intro .  induction xe as [ x e ] .  induction e .  simpl . unfold ff . unfold ezmap1 . unfold d1 .   change (hfiberpair g (f x) ( pr1 fs x) ) with ( ezmap f g z fs x ) .  apply ( hfibertriangle2 f ( hfiberpair f ( invmap (ezweq f g z fs) (ezmap f g z fs x) ) _ ) ( hfiberpair f x ( idpath _ ) ) ( homotinvweqweq ( ezweq f g z fs ) x ) ) . simpl .  set ( e1 := pathsinv0 ( pathscomp0rid (maponpaths f (homotinvweqweq (ezweq f g z fs) x) ) ) ) . assert ( e2 : paths (maponpaths (hfiberpr1 g z) (homotweqinvweq (ezweq f g z fs) ( ( ezmap f g z fs ) x))) (maponpaths f (homotinvweqweq (ezweq f g z fs) x)) ) . set ( e3 := maponpaths ( fun e : _ => maponpaths ( hfiberpr1 g z ) e ) ( pathsinv0  ( homotweqinvweqweq ( ezweq f g z fs ) x ) ) ) .  simpl in e3 .  set ( e4 := maponpathscomp (ezmap f g z (pr1 fs)) (hfiberpr1 g z) (homotinvweqweq (ezweq f g z fs) x) ) .   simpl in e4 . apply ( pathscomp0 e3 e4 ) . apply ( pathscomp0 e2 e1 ) . 
apply ( gradth _ _ egf efg ) . Defined . 

Definition ezweq1 { X Y Z : UU } ( f : X -> Y ) ( g : Y -> Z ) ( z : Z ) ( fs : fibseqstr f g z ) ( y : Y ) := weqpair _ ( isweqezmap1 f g z fs y ) . 
Definition fibseq1 { X Y Z : UU } (f:X -> Y) (g:Y->Z) (z:Z) ( fs : fibseqstr f g z )(y:Y) : fibseqstr ( d1 f g z fs y) f y := fibseqstrpair _ _ _ _ ( isweqezmap1 f g z fs y ) . 



(** Explitcit description of the first map in the second derived sequence. *)

Definition d2 { X Y Z : UU } (f:X -> Y) (g:Y->Z) (z:Z) ( fs : fibseqstr f g z ) (y:Y) (x:X) ( e : paths (f x) y ) : paths (g y) z := pathscomp0 ( maponpaths g ( pathsinv0 e ) ) ( ( pr1 fs ) x ) . 
Definition ezweq2 { X Y Z : UU } (f:X -> Y) (g:Y->Z) (z:Z) ( fs : fibseqstr f g z ) (y:Y) (x:X) : weq ( paths (f x) y ) ( hfiber  (d1 f g z fs y) x ) := ezweq1 (d1 f g z fs y) f y ( fibseq1 f g z fs y )  x.
Definition fibseq2  { X Y Z : UU } (f:X -> Y) (g:Y->Z) (z:Z) ( fs : fibseqstr f g z ) (y:Y) (x:X) : fibseqstr ( d2 f g z fs y x ) ( d1 f g z fs y ) x := fibseqstrpair _ _ _ _ ( isweqezmap1 (d1 f g z fs y) f y ( fibseq1 f g z fs y ) x ) .





(** *** Fibration sequences based on [ ( tpair P z : P z -> total2 P ) ( pr1 : total2 P -> Z ) ] (  the "pr1-case" )    *) 



(** Construction of the fibration sequence. *)

Definition ezmappr1 { Z : UU } ( P : Z -> UU ) ( z : Z ) : P z -> hfiber ( @pr1 Z P ) z := fun p : P z => tpair _ ( tpair _  z p ) ( idpath z ).

Definition invezmappr1 { Z : UU } ( P : Z -> UU) ( z : Z ) : hfiber ( @pr1 Z P ) z  -> P z := fun te  : hfiber ( @pr1 Z P ) z =>
match te with 
tpair _ t e => transportf P e ( pr2 t ) 
end.

Definition isweqezmappr1 { Z : UU } ( P : Z -> UU ) ( z : Z ) : isweq ( ezmappr1 P z ).
Proof. intros. 
assert ( egf : forall x: P z , paths (invezmappr1 _ z ((ezmappr1 P z ) x)) x). intro. unfold ezmappr1. unfold invezmappr1. simpl. apply idpath. 
assert ( efg : forall x: hfiber  (@pr1 Z P) z , paths (ezmappr1 _ z (invezmappr1 P z x)) x). intros.  induction x as [ x t0 ]. induction t0. simpl in x.  simpl. induction x. simpl. unfold transportf. unfold ezmappr1. apply idpath. 
apply (gradth _ _ egf efg ). Defined. 

Definition ezweqpr1 { Z : UU } ( P : Z -> UU ) ( z : Z ) := weqpair _ ( isweqezmappr1 P z ) .

Lemma isfibseqpr1 { Z : UU } ( P : Z -> UU ) ( z : Z ) : isfibseq  (fun p : P z => tpair _ z p) ( @pr1 Z P ) z (fun p: P z => idpath z ).
Proof. intros. unfold isfibseq. unfold ezmap.  apply isweqezmappr1. Defined.

Definition fibseqpr1 { Z : UU } ( P : Z -> UU ) ( z : Z ) : fibseqstr (fun p : P z => tpair _ z p) ( @pr1 Z P ) z := fibseqstrpair _ _ _ _ ( isfibseqpr1 P z ) .


(** The main weak equivalence defined by the first derived of [ fibseqpr1 ]. *)

Definition ezweq1pr1 { Z : UU } ( P : Z -> UU ) ( z : Z ) ( zp : total2 P ) : weq ( paths ( pr1 zp) z )  ( hfiber ( tpair P z ) zp ) := ezweq1 _ _ z ( fibseqpr1 P z ) zp .   







(** *** Fibration sequences based on [ ( hfiberpr1 : hfiber g z -> Y ) ( g : Y -> Z ) ] (the "g-case")  *)


Theorem isfibseqg { Y Z : UU } (g:Y -> Z) (z:Z) : isfibseq  (hfiberpr1  g z) g z (fun ye: _ => pr2  ye).
Proof. intros. assert (Y0:forall ye': hfiber  g z, paths ye' (ezmap (hfiberpr1  g z) g z (fun ye: _ => pr2  ye) ye')). intro. apply tppr. apply (isweqhomot  _ _ Y0 (idisweq _ )).  Defined.

Definition ezweqg { Y Z : UU } (g:Y -> Z) (z:Z) := weqpair _ ( isfibseqg g z ) .
Definition fibseqg { Y Z : UU } (g:Y -> Z) (z:Z) : fibseqstr (hfiberpr1  g z) g z := fibseqstrpair _ _ _ _ ( isfibseqg g z ) . 


(** The first derived of [ fibseqg ].  *)

Definition d1g  { Y Z : UU} ( g : Y -> Z ) ( z : Z ) ( y : Y ) : paths ( g y ) z -> hfiber g z := hfiberpair g y . 

(** note that [ d1g ] coincides with [ d1 _ _ _ ( fibseqg g z ) ] which makes the following two definitions possible. *)

Definition ezweq1g { Y Z : UU } (g:Y -> Z) (z:Z) (y:Y) : weq (paths (g y) z) (hfiber (hfiberpr1 g z) y) := weqpair _ (isweqezmap1 (hfiberpr1  g z) g z ( fibseqg g z ) y) .
Definition fibseq1g { Y Z : UU } (g:Y -> Z) (z:Z) ( y : Y) : fibseqstr (d1g g z y ) ( hfiberpr1 g z ) y := fibseqstrpair _ _ _ _ (isweqezmap1 (hfiberpr1  g z) g z  ( fibseqg g z ) y) . 


(** The second derived of [ fibseqg ]. *) 

Definition d2g { Y Z : UU } (g:Y -> Z) { z : Z } ( y : Y ) ( ye' : hfiber  g z ) ( e: paths (pr1 ye') y ) :  paths (g y) z := pathscomp0 ( maponpaths g ( pathsinv0 e ) ) ( pr2  ye' ) .

(** note that [ d2g ] coincides with [ d2 _ _ _ ( fibseqg g z ) ] which makes the following two definitions possible. *)

Definition ezweq2g { Y Z : UU } (g:Y -> Z) { z : Z } ( y : Y ) ( ye' : hfiber  g z ) : weq (paths (pr1 ye') y) (hfiber ( hfiberpair g y ) ye') := ezweq2 _ _ _ ( fibseqg g z ) _ _ .
Definition fibseq2g { Y Z : UU } (g:Y -> Z) { z : Z } ( y : Y ) ( ye' : hfiber  g z ) : fibseqstr ( d2g g y ye' ) ( hfiberpair g y ) ye' := fibseq2 _ _ _ ( fibseqg g z ) _ _ . 


(** The third derived of [ fibseqg ] and an explicit description of the corresponding first map. *)

Definition d3g { Y Z : UU } (g:Y -> Z) { z : Z } ( y : Y ) ( ye' : hfiber g z ) ( e : paths ( g y ) z ) : paths ( hfiberpair  g y e ) ye' -> paths ( pr1 ye' ) y := d2 (d1g  g z y) (hfiberpr1 g z) y ( fibseq1g g z y ) ye' e . 

Lemma homotd3g { Y Z : UU } ( g : Y -> Z ) { z : Z } ( y : Y ) ( ye' : hfiber  g z ) ( e : paths ( g y ) z ) ( ee : paths ( hfiberpair g y e) ye' ) : paths (d3g g y ye' e ee) ( maponpaths ( @pr1 _ _ ) ( pathsinv0 ee ) ) .
Proof. intros. unfold d3g . unfold d2 .  simpl .  apply pathscomp0rid. Defined .  

Definition ezweq3g { Y Z : UU } (g:Y -> Z) { z : Z } ( y : Y ) ( ye' : hfiber g z ) ( e : paths ( g y ) z ) := ezweq2 (d1g  g z y) (hfiberpr1 g z) y ( fibseq1g g z y ) ye' e . 
Definition fibseq3g { Y Z : UU } (g:Y -> Z) { z : Z } ( y : Y ) ( ye' : hfiber g z ) ( e : paths ( g y ) z ) := fibseq2 (d1g  g z y) (hfiberpr1 g z) y ( fibseq1g g z y ) ye' e .





(** *** Fibration sequence of h-fibers defined by a composable pair of functions (the "hf-case") 

We construct a fibration sequence based on [ ( hfibersftogf f g z ye : hfiber f ( pr1 ye )  -> hfiber gf z ) ( hfibersgftog f g z : hfiber gf z -> hfiber g z ) ]. *) 




Definition hfibersftogf { X Y Z : UU } ( f : X -> Y ) ( g : Y -> Z ) ( z : Z ) ( ye : hfiber g z ) ( xe : hfiber f ( pr1 ye ) ) : hfiber ( funcomp f g ) z .
Proof . intros . split with ( pr1 xe ) .  apply ( pathscomp0 ( maponpaths g ( pr2 xe ) ) ( pr2 ye ) ) .  Defined .  



Definition ezmaphf { X Y Z : UU } ( f : X -> Y ) ( g : Y -> Z ) ( z : Z ) ( ye : hfiber g z ) ( xe : hfiber f ( pr1 ye ) ) : hfiber ( hfibersgftog f g z ) ye .
Proof . intros . split with ( hfibersftogf f g z ye xe ) . simpl . apply ( hfibertriangle2 g (hfiberpair g (f (pr1 xe)) (pathscomp0 (maponpaths g (pr2 xe)) ( pr2 ye ) )) ye ( pr2 xe ) ) .  simpl . apply idpath .  Defined . 

Definition invezmaphf { X Y Z : UU } ( f : X -> Y ) ( g : Y -> Z ) ( z : Z ) ( ye : hfiber g z ) ( xee' : hfiber ( hfibersgftog f g z ) ye ) : hfiber f ( pr1 ye ) .
Proof . intros .  split with ( pr1 ( pr1 xee' ) ) .  apply ( maponpaths ( hfiberpr1 _ _ ) ( pr2 xee' ) ) . Defined . 

Definition ffgg { X Y Z : UU } ( f : X -> Y ) ( g : Y -> Z ) ( z : Z ) ( ye : hfiber g z ) ( xee' : hfiber  ( hfibersgftog f g z ) ye ) : hfiber  ( hfibersgftog f g z ) ye .
Proof . intros . induction ye as [ y e ] . induction e . unfold hfibersgftog .  unfold hfibersgftog in xee' . induction xee' as [ xe e' ] . induction xe as [ x e ] .  simpl in e' . split with ( hfiberpair ( funcomp f g ) x ( pathscomp0 ( maponpaths g (maponpaths (hfiberpr1 g (g y)) e') ) ( idpath (g y ))) ) .  simpl . apply ( hfibertriangle2 _ (hfiberpair g (f x) (( pathscomp0 ( maponpaths g (maponpaths (hfiberpr1 g (g y)) e') ) ( idpath (g y ))))) ( hfiberpair g y ( idpath _ ) ) ( maponpaths ( hfiberpr1 _ _ ) e' ) ( idpath _ ) )  .  Defined .

Definition homotffggid   { X Y Z : UU } ( f : X -> Y ) ( g : Y -> Z ) ( z : Z ) ( ye : hfiber g z ) ( xee' : hfiber  ( hfibersgftog f g z ) ye ) : paths ( ffgg f g z ye xee' ) xee' .
Proof . intros .  induction ye as [ y e ] . induction e .  induction xee' as [ xe e' ] .  induction e' .  induction xe as [ x e ] . induction e .  simpl . apply idpath . Defined . 

Theorem isweqezmaphf { X Y Z : UU } ( f : X -> Y ) ( g : Y -> Z ) ( z : Z ) ( ye : hfiber g z ) : isweq ( ezmaphf f g z ye ) . 
Proof . intros . set ( ff := ezmaphf f g z ye ) . set ( gg := invezmaphf f g z ye ) . 
assert ( egf : forall xe : _ , paths ( gg ( ff xe ) ) xe ) . induction ye as [ y e ] . induction e .  intro xe .   apply ( hfibertriangle2 f ( gg ( ff xe ) ) xe ( idpath ( pr1 xe ) ) ) . induction xe as [ x ex ] . simpl in ex . induction ( ex ) .  simpl .   apply idpath . 
assert ( efg : forall xee' : _ , paths ( ff ( gg xee' ) ) xee' ) . induction ye as [ y e ] . induction e .  intro xee' . 
assert ( hint : paths ( ff ( gg xee' ) ) ( ffgg f g ( g y ) ( hfiberpair g y ( idpath _ ) ) xee'  ) ) .  induction xee' as [ xe e' ] .   induction xe as [ x e ] .  apply idpath . 
apply ( pathscomp0 hint ( homotffggid _ _ _ _ xee' ) ) . 
apply ( gradth _ _ egf efg ) . Defined .  


Definition ezweqhf { X Y Z : UU } ( f : X -> Y ) ( g : Y -> Z ) ( z : Z ) ( ye : hfiber g z ) : weq ( hfiber f ( pr1 ye ) ) ( hfiber  ( hfibersgftog f g z ) ye ) := weqpair _ ( isweqezmaphf f g z ye ) . 
Definition fibseqhf  { X Y Z : UU } (f:X -> Y)(g: Y -> Z)(z:Z)(ye: hfiber  g z) : fibseqstr (hfibersftogf f g z ye) (hfibersgftog f g z) ye := fibseqstrpair _ _ _ _ ( isweqezmaphf f g z ye ) . 

Definition isweqinvezmaphf  { X Y Z : UU } ( f : X -> Y ) ( g : Y -> Z ) ( z : Z ) ( ye : hfiber g z ) : isweq ( invezmaphf f g z ye ) := pr2 ( invweq ( ezweqhf f g z ye ) ) .


Corollary weqhfibersgwtog { X Y Z : UU } ( w : weq X Y ) ( g : Y -> Z ) ( z : Z ) : weq ( hfiber ( funcomp w g ) z ) ( hfiber g z ) .
Proof. intros . split with ( hfibersgftog w g z ) .  intro ye . apply ( iscontrweqf ( ezweqhf w g z ye ) ( ( pr2 w ) ( pr1 ye ) ) ) . Defined .
























(** ** Fiber-wise weak equivalences. 


Theorems saying that a fiber-wise morphism between total spaces is a weak equivalence if and only if all the morphisms between the fibers are weak equivalences. *)


Definition totalfun { X : UU } ( P Q : X -> UU ) (f: forall x:X, P x -> Q x) := (fun z: total2 P => tpair Q (pr1  z) (f (pr1  z) (pr2  z))).


Theorem isweqtotaltofib { X : UU } ( P Q : X -> UU) (f: forall x:X, P x -> Q x):
isweq (totalfun _ _ f) -> forall x:X, isweq (f x).
Proof. intros X P Q f X0 x. set (totp:= total2 P). set (totq := total2 Q).  set (totf:= (totalfun _ _ f)). set (pip:= fun z: totp => pr1  z). set (piq:= fun z: totq => pr1  z). 

set (hfx:= hfibersgftog totf piq x).  simpl in hfx. 
assert (H: isweq hfx). unfold isweq. intro y. 
set (int:= invezmaphf totf piq x y). 
assert (X1:isweq int). apply (isweqinvezmaphf totf piq x y). induction y as [ t e ]. 
assert (is1: iscontr (hfiber  totf t)). apply (X0 t). apply (iscontrweqb  ( weqpair int X1 ) is1).   
set (ip:= ezmappr1 P x). set (iq:= ezmappr1 Q x). set (h:= fun p: P x => hfx (ip p)).  
assert (is2: isweq h). apply (twooutof3c ip hfx (isweqezmappr1 P x) H). set (h':= fun p: P x => iq ((f x) p)). 
assert (ee: forall p:P x, paths (h p) (h' p)). intro. apply idpath.  
assert (X2:isweq h'). apply (isweqhomot   h h' ee is2). 
apply (twooutof3a (f x) iq X2). 
apply (isweqezmappr1 Q x). Defined.


Definition weqtotaltofib { X : UU } ( P Q : X -> UU ) ( f : forall x : X , P x -> Q x ) ( is : isweq ( totalfun _ _ f ) ) ( x : X ) : weq ( P x ) ( Q x ) := weqpair _ ( isweqtotaltofib P Q f is x ) . 
 

Theorem isweqfibtototal { X : UU } ( P Q : X -> UU) (f: forall x:X, weq ( P x ) ( Q x ) ) : isweq (totalfun _ _ f).
Proof. intros X P Q f . set (fpq:= totalfun P Q f). set (pr1p:= fun z: total2 P => pr1  z). set (pr1q:= fun z: total2 Q => pr1  z). unfold isweq. intro xq.   set (x:= pr1q xq). set (xqe:= hfiberpair  pr1q  xq (idpath _)). set (hfpqx:= hfibersgftog fpq pr1q x). 

assert (isint: iscontr (hfiber  hfpqx xqe)). 
assert (isint1: isweq hfpqx). set (ipx:= ezmappr1 P x). set (iqx:= ezmappr1 Q x).   set (diag:= fun p:P x => (iqx ((f x) p))). 
assert (is2: isweq diag).  apply (twooutof3c (f x) iqx (pr2 ( f x) ) (isweqezmappr1 Q x)).  apply (twooutof3b  ipx hfpqx (isweqezmappr1 P x) is2).  unfold isweq in isint1.  apply (isint1 xqe). 
set (intmap:= invezmaphf  fpq pr1q x xqe). apply (iscontrweqf  ( weqpair intmap (isweqinvezmaphf fpq pr1q x xqe) ) isint). 
Defined.

Definition weqfibtototal { X : UU } ( P Q : X -> UU) (f: forall x:X, weq ( P x ) ( Q x ) ) := weqpair _ ( isweqfibtototal P Q f ) .






(** ** Homotopy fibers of the function [fpmap: total2 X (P f) -> total2 Y P].

Given [ X Y ] in [ UU ], [ P:Y -> UU ] and [ f: X -> Y ] we get a function [ fpmap: total2 X (P f) -> total2 Y P ]. The main theorem of this section asserts that the homotopy fiber of fpmap over [ yp:total Y P ] is naturally weakly equivalent to the homotopy fiber of [ f ] over [ pr1 yp ]. In particular, if  [ f ] is a weak equivalence then so is [ fpmap ]. *)


Definition fpmap { X Y : UU } (f: X -> Y) ( P:Y-> UU) : total2 ( fun x => P ( f x ) ) -> total2 P := 
(fun z:total2 (fun x:X => P (f x)) => tpair P (f (pr1  z)) (pr2  z)).


Definition hffpmap2 { X Y : UU } (f: X -> Y) (P:Y-> UU):  total2 ( fun x => P ( f x ) ) -> total2 (fun u:total2 P => hfiber  f (pr1  u)).
Proof. intros X Y f P X0. set (u:= fpmap f P X0).  split with u. set (x:= pr1  X0).  split with x. simpl. apply idpath. Defined.


Definition hfiberfpmap { X Y : UU } (f:X -> Y)(P:Y-> UU)(yp: total2 P): hfiber  (fpmap f P) yp -> hfiber  f (pr1  yp).
Proof. intros X Y f P yp X0. set (int1:= hfibersgftog (hffpmap2  f P) (fun u: (total2 (fun u:total2 P => hfiber  f (pr1  u))) => (pr1  u)) yp).  set (phi:= invezmappr1 (fun u:total2 P => hfiber  f (pr1  u)) yp). apply (phi (int1 X0)).   Defined. 



Lemma centralfiber { X : UU } (P:X -> UU)(x:X): isweq (fun p: P x => tpair (fun u: coconusfromt X x => P ( pr1  u)) (coconusfromtpair X (idpath x)) p).
Proof. intros. set (f:= fun p: P x => tpair (fun u: coconusfromt X x => P(pr1  u)) (coconusfromtpair X (idpath x)) p). set (g:= fun z: total2 (fun u: coconusfromt X x => P ( pr1  u)) => transportf P (pathsinv0 (pr2  (pr1  z))) (pr2  z)).  

assert (efg: forall  z: total2 (fun u: coconusfromt X x => P ( pr1  u)), paths (f (g z)) z). intro. induction z as [ t x0 ]. induction t as [t x1 ].   simpl. induction x1. simpl. apply idpath. 

assert (egf: forall p: P x , paths (g (f p)) p).  intro. apply idpath.  

apply (gradth f g egf efg). Defined. 


Lemma isweqhff { X Y : UU } (f: X -> Y)(P:Y-> UU): isweq (hffpmap2  f P). 
Proof. intros. set (int:= total2 (fun x:X => total2 (fun u: coconusfromt Y (f x) => P (pr1  u)))). set (intpair:= tpair (fun x:X => total2 (fun u: coconusfromt Y (f x) => P (pr1  u)))).  set (toint:= fun z: (total2 (fun u : total2 P => hfiber  f (pr1  u))) => intpair (pr1  (pr2  z)) (tpair  (fun u: coconusfromt Y (f (pr1  (pr2  z))) => P (pr1  u)) (coconusfromtpair _ (pr2  (pr2  z))) (pr2  (pr1  z)))). set (fromint:= fun z: int => tpair (fun u:total2 P => hfiber  f (pr1  u)) (tpair P (pr1  (pr1  (pr2  z))) (pr2  (pr2  z))) (hfiberpair  f  (pr1  z) (pr2  (pr1  (pr2  z))))). assert (fromto: forall u:(total2 (fun u : total2 P => hfiber  f (pr1  u))), paths (fromint (toint u)) u). simpl in toint. simpl in fromint. simpl. intro u. induction u as [ t x ]. induction x. induction t as [ p0 p1 ] . simpl. unfold toint. unfold fromint. simpl. apply idpath. assert (tofrom: forall u:int, paths (toint (fromint u)) u). intro. induction u as [ t x ]. induction x as [ t0 x ]. induction t0. simpl in x. simpl. unfold fromint. unfold toint. simpl. apply idpath. assert (is: isweq toint). apply (gradth  toint fromint fromto tofrom).  clear tofrom. clear fromto.  clear fromint.

set (h:= fun u: total2 (fun x:X => P (f x)) => toint ((hffpmap2  f P) u)). simpl in h. 

assert (l1: forall x:X, isweq (fun p: P (f x) => tpair  (fun u: coconusfromt _ (f x) => P (pr1  u)) (coconusfromtpair _ (idpath  (f x))) p)). intro. apply (centralfiber P (f x)).  

assert (X0:isweq h). apply (isweqfibtototal  (fun x:X => P (f x))  (fun x:X => total2 (fun u: coconusfromt _ (f x) => P (pr1  u))) (fun x:X =>  weqpair _  ( l1 x ) ) ).   

apply (twooutof3a (hffpmap2  f P) toint X0 is). Defined. 




Theorem isweqhfiberfp { X Y : UU } (f:X -> Y)(P:Y-> UU)(yp: total2 P): isweq (hfiberfpmap  f P yp).
Proof. intros. set (int1:= hfibersgftog (hffpmap2  f P) (fun u: (total2 (fun u:total2 P => hfiber  f (pr1  u))) => (pr1  u)) yp). assert (is1: isweq int1). simpl in int1 . apply ( pr2 ( weqhfibersgwtog ( weqpair _ ( isweqhff f P ) ) (fun u : total2 (fun u : total2 P => hfiber f (pr1 u)) => pr1 u) yp ) ) .  set (phi:= invezmappr1 (fun u:total2 P => hfiber  f (pr1  u)) yp). assert (is2: isweq phi).  apply ( pr2 ( invweq ( ezweqpr1 (fun u:total2 P => hfiber  f (pr1  u)) yp ) ) ) . apply (twooutof3c int1 phi is1 is2).   Defined. 


Corollary isweqfpmap { X Y : UU } ( w : weq X Y )(P:Y-> UU) :  isweq (fpmap w P).
Proof. intros. unfold isweq.   intro y.  set (h:=hfiberfpmap w P y). 
assert (X1:isweq h). apply isweqhfiberfp. 
assert (is: iscontr (hfiber w (pr1  y))). apply ( pr2 w ). apply (iscontrweqb  ( weqpair h X1 ) is). Defined. 

Definition weqfp { X Y : UU } ( w : weq X Y )(P:Y-> UU) := weqpair _ ( isweqfpmap w P ) .


(** *** Total spaces of families over a contractible base *)

Definition fromtotal2overunit ( P : unit -> UU ) ( tp : total2 P ) : P tt .
Proof . intros . induction tp as [ t p ] . induction t . apply p . Defined .

Definition tototal2overunit   ( P : unit -> UU ) ( p : P tt ) : total2 P  := tpair P tt p . 

Theorem weqtotal2overunit ( P : unit -> UU ) : weq ( total2 P ) ( P tt ) .
Proof. intro . set ( f := fromtotal2overunit P ) . set ( g := tototal2overunit P ) . split with f . 
assert ( egf : forall a : _ , paths ( g ( f a ) ) a ) . intro a . induction a as [ t p ] . induction t . apply idpath .
assert ( efg : forall a : _ , paths ( f ( g a ) ) a ) . intro a . apply idpath .    
apply ( gradth _ _ egf efg ) . Defined . 



(** ** The maps between total spaces of families given by a map between the bases of the families and maps between the corresponding members of the families *)


Definition bandfmap { X Y : UU }(f: X -> Y) ( P : X -> UU)(Q: Y -> UU)(fm: forall x:X, P x -> (Q (f x))): total2 P -> total2 Q:= fun xp:_ =>
match xp with
tpair _ x p => tpair Q (f x) (fm x p)
end.

Theorem isweqbandfmap { X Y : UU } (w : weq X Y ) (P:X -> UU)(Q: Y -> UU)( fw : forall x:X, weq ( P x) (Q (w x))) : isweq (bandfmap  _ P Q fw).
Proof. intros. set (f1:= totalfun P _ fw). set (is1:= isweqfibtototal P (fun x:X => Q (w x)) fw ).  set (f2:= fpmap w Q).  set (is2:= isweqfpmap w Q ). 
assert (h: forall xp: total2 P, paths (f2 (f1 xp)) (bandfmap  w P Q fw xp)). intro. induction xp. apply idpath.  apply (isweqhomot  _ _ h (twooutof3c f1 f2 is1 is2)). Defined.

Definition weqbandf { X Y : UU } (w : weq X Y ) (P:X -> UU)(Q: Y -> UU)( fw : forall x:X, weq ( P x) (Q (w x))) := weqpair _ ( isweqbandfmap w P Q fw ) .






























(** ** Homotopy fiber squares *)




(** *** Homotopy commutative squares *)


Definition commsqstr { X X' Y Z : UU } ( g' : Z -> X' ) ( f' : X' -> Y ) ( g : Z -> X ) ( f : X -> Y ) := forall ( z : Z ) , paths   ( f' ( g' z ) ) ( f ( g z ) ) .


Definition hfibersgtof'  { X X' Y Z : UU } ( f : X -> Y ) ( f' : X' -> Y ) ( g : Z -> X ) ( g' : Z -> X' ) ( h : commsqstr g' f' g f ) ( x : X ) ( ze : hfiber g x ) : hfiber f' ( f x )  .
Proof. intros . induction ze as [ z e ] . split with ( g' z ) .    apply ( pathscomp0  ( h z )  ( maponpaths f e )  ) . Defined . 

Definition hfibersg'tof  { X X' Y Z : UU } ( f : X -> Y ) ( f' : X' -> Y ) ( g : Z -> X ) ( g' : Z -> X' ) ( h : commsqstr g' f' g f ) ( x' : X' ) ( ze : hfiber g' x' ) : hfiber f ( f' x' )  .
Proof. intros . induction ze as [ z e ] . split with ( g z ) .    apply ( pathscomp0 ( pathsinv0 ( h z ) ) ( maponpaths f' e ) ) . Defined . 


Definition transposcommsqstr { X X' Y Z : UU } ( f : X -> Y ) ( f' : X' -> Y ) ( g : Z -> X ) ( g' : Z -> X' ) : commsqstr g' f' g f -> commsqstr g f g' f' := fun h : _ => fun z : Z => ( pathsinv0 ( h z ) ) . 


(** *** Short complexes and homotopy commutative squares *)

Lemma complxstrtocommsqstr { X Y Z : UU } ( f : X -> Y ) ( g : Y -> Z ) ( z : Z ) ( h : complxstr f g z ) : commsqstr f g ( fun x : X => tt ) ( fun t : unit => z ) .
Proof. intros .  assumption .   Defined . 


Lemma commsqstrtocomplxstr { X Y Z : UU } ( f : X -> Y ) ( g : Y -> Z ) ( z : Z ) ( h : commsqstr f  g ( fun x : X => tt ) ( fun t : unit => z ) ) : complxstr f g z .
Proof. intros . assumption .   Defined . 


(** *** Homotopy fiber products *)



Definition hfp {X X' Y:UU} (f:X -> Y) (f':X' -> Y):= total2 (fun xx' : dirprod X X'  => paths ( f' ( pr2 xx' ) ) ( f ( pr1 xx' ) ) ) .
Definition hfpg {X X' Y:UU} (f:X -> Y) (f':X' -> Y) : hfp f f' -> X := fun xx'e => ( pr1 ( pr1 xx'e ) ) .
Definition hfpg' {X X' Y:UU} (f:X -> Y) (f':X' -> Y) : hfp f f' -> X' := fun xx'e => ( pr2 ( pr1 xx'e ) ) .

Definition commsqZtohfp { X X' Y Z : UU } ( f : X -> Y ) ( f' : X' -> Y ) ( g : Z -> X ) ( g' : Z -> X' ) ( h : commsqstr g' f' g f ) : Z -> hfp f f' := fun z : _ => tpair _ ( dirprodpair ( g z ) ( g' z ) ) ( h z ) .

Definition commsqZtohfphomot  { X X' Y Z : UU } ( f : X -> Y ) ( f' : X' -> Y ) ( g : Z -> X ) ( g' : Z -> X' ) ( h : commsqstr g' f' g f  ) : forall z : Z , paths ( hfpg _ _ ( commsqZtohfp _ _ _ _ h z ) ) ( g z ) := fun z : _ => idpath _ . 

Definition commsqZtohfphomot'  { X X' Y Z : UU } ( f : X -> Y ) ( f' : X' -> Y ) ( g : Z -> X ) ( g' : Z -> X' ) ( h : commsqstr g' f' g f  ) : forall z : Z , paths ( hfpg' _ _ ( commsqZtohfp _ _ _ _ h z ) ) ( g' z ) := fun z : _ => idpath _ . 


Definition hfpoverX {X X' Y:UU} (f:X -> Y) (f':X' -> Y) := total2 (fun x : X => hfiber  f' ( f x ) ) .
Definition hfpoverX' {X X' Y:UU} (f:X -> Y) (f':X' -> Y) := total2 (fun x' : X' => hfiber  f (f' x' ) ) .


Definition weqhfptohfpoverX {X X' Y:UU} (f:X -> Y) (f':X' -> Y) : weq ( hfp f f' ) ( hfpoverX f f' ) .
Proof. intros . apply ( weqtotal2asstor ( fun x : X => X' ) ( fun  xx' : dirprod X X'  => paths  ( f' ( pr2 xx' ) ) ( f ( pr1 xx' ) ) ) ) .   Defined . 


Definition weqhfptohfpoverX' {X X' Y:UU} (f:X -> Y) (f':X' -> Y) : weq ( hfp f f' ) ( hfpoverX' f f' ) .
Proof. intros .  set ( w1 := weqfp ( weqdirprodcomm X X' ) ( fun xx' : dirprod X' X  => paths ( f' ( pr1 xx' ) ) ( f ( pr2 xx' ) ) ) ) .  simpl in w1 .  
set ( w2 := weqfibtototal ( fun  x'x : dirprod X' X  => paths  ( f' ( pr1 x'x ) ) ( f ( pr2 x'x ) ) ) ( fun  x'x : dirprod X' X  => paths   ( f ( pr2 x'x ) ) ( f' ( pr1 x'x ) ) ) ( fun x'x : _ => weqpathsinv0  ( f' ( pr1 x'x ) ) ( f ( pr2 x'x ) ) ) ) . set ( w3 := weqtotal2asstor ( fun x' : X' => X ) ( fun  x'x : dirprod X' X  => paths   ( f ( pr2 x'x ) ) ( f' ( pr1 x'x ) ) ) ) .  simpl in w3 .  apply ( weqcomp ( weqcomp w1 w2 ) w3 )   .  Defined . 


Lemma weqhfpcomm { X X' Y : UU } ( f : X -> Y ) ( f' : X' -> Y ) : weq ( hfp f f' ) ( hfp f' f ) .
Proof . intros . set ( w1 :=  weqfp ( weqdirprodcomm X X' ) ( fun xx' : dirprod X' X  => paths ( f' ( pr1 xx' ) ) ( f ( pr2 xx' ) ) ) ) .  simpl in w1 .  set ( w2 := weqfibtototal ( fun  x'x : dirprod X' X  => paths  ( f' ( pr1 x'x ) ) ( f ( pr2 x'x ) ) ) ( fun  x'x : dirprod X' X  => paths   ( f ( pr2 x'x ) ) ( f' ( pr1 x'x ) ) ) ( fun x'x : _ => weqpathsinv0  ( f' ( pr1 x'x ) ) ( f ( pr2 x'x ) ) ) ) . apply ( weqcomp w1 w2 ) .     Defined . 


Definition commhfp {X X' Y:UU} (f:X -> Y) (f':X' -> Y) : commsqstr ( hfpg' f f' ) f' ( hfpg f f' ) f := fun xx'e : hfp f f' => pr2 xx'e . 


(** *** Homotopy fiber products and homotopy fibers *)

Definition  hfibertohfp { X Y : UU } ( f : X -> Y ) ( y : Y ) ( xe : hfiber f y ) : hfp ( fun t : unit => y ) f :=  tpair ( fun tx : dirprod unit X => paths ( f ( pr2 tx ) ) y ) ( dirprodpair tt ( pr1 xe ) ) ( pr2 xe )  . 

Definition hfptohfiber { X Y : UU } ( f : X -> Y ) ( y : Y ) ( hf : hfp ( fun t : unit => y ) f ) : hfiber f y := hfiberpair f ( pr2 ( pr1 hf ) ) ( pr2 hf ) .

Lemma weqhfibertohfp  { X Y : UU } ( f : X -> Y ) ( y : Y ) : weq ( hfiber f y )  ( hfp ( fun t : unit => y ) f ) .
Proof . intros . set ( ff := hfibertohfp f y ) . set ( gg := hfptohfiber f y ) . split with ff .
assert ( egf : forall xe : _ , paths ( gg ( ff xe ) ) xe ) . intro . induction xe . apply idpath .
assert ( efg : forall hf : _ , paths ( ff ( gg hf ) ) hf ) . intro . induction hf as [ tx e ] . induction tx as [ t x ] . induction t .   apply idpath .
apply ( gradth _ _ egf efg ) . Defined .  







(** *** Homotopy fiber squares *)


Definition ishfsq { X X' Y Z : UU } ( f : X -> Y ) ( f' : X' -> Y ) ( g : Z -> X ) ( g' : Z -> X' ) ( h : commsqstr g' f' g f  ) :=  isweq ( commsqZtohfp f f' g g' h ) .

Definition hfsqstr  { X X' Y Z : UU } ( f : X -> Y ) ( f' : X' -> Y ) ( g : Z -> X ) ( g' : Z -> X' ) := total2 ( fun h : commsqstr g' f' g f  => isweq ( commsqZtohfp f f' g g' h ) ) .
Definition hfsqstrpair { X X' Y Z : UU } ( f : X -> Y ) ( f' : X' -> Y ) ( g : Z -> X ) ( g' : Z -> X' ) := tpair ( fun h : commsqstr g' f' g f  => isweq ( commsqZtohfp f f' g g' h ) ) .
Definition hfsqstrtocommsqstr { X X' Y Z : UU } ( f : X -> Y ) ( f' : X' -> Y ) ( g : Z -> X ) ( g' : Z -> X' ) : hfsqstr f f' g g' -> commsqstr g' f' g f  := @pr1 _ ( fun h : commsqstr g' f' g f  => isweq ( commsqZtohfp f f' g g' h ) ) .
Coercion hfsqstrtocommsqstr : hfsqstr >-> commsqstr . 

Definition weqZtohfp  { X X' Y Z : UU } ( f : X -> Y ) ( f' : X' -> Y ) ( g : Z -> X ) ( g' : Z -> X' ) ( hf : hfsqstr f f' g g' ) : weq Z ( hfp f f' ) := weqpair _ ( pr2 hf ) .

Lemma isweqhfibersgtof' { X X' Y Z : UU } ( f : X -> Y ) ( f' : X' -> Y ) ( g : Z -> X ) ( g' : Z -> X' ) ( hf : hfsqstr f f' g g' ) ( x : X ) : isweq ( hfibersgtof' f f' g g' hf x ) .
Proof. intros . set ( is := pr2 hf ) . set ( h := pr1 hf ) . 
set ( a := weqtococonusf g ) . set ( c := weqpair _ is ) .  set ( d := weqhfptohfpoverX f f' ) .  set ( b0 := totalfun _ _ ( hfibersgtof' f f' g g' h ) ) .    
assert ( h1 : forall z : Z , paths ( d ( c z ) ) ( b0 ( a z ) ) ) . intro . simpl .  unfold b0 . unfold a .   unfold weqtococonusf . unfold tococonusf .   simpl .  unfold totalfun . simpl . assert ( e : paths ( h  z ) ( pathscomp0 (h z) (idpath (f (g z))) ) ) . apply ( pathsinv0 ( pathscomp0rid _ ) ) .  induction e .  apply idpath .
assert ( is1 : isweq ( fun z : _ => b0 ( a z ) ) ) . apply ( isweqhomot _ _ h1 ) .   apply ( twooutof3c _ _ ( pr2 c ) ( pr2 d ) ) .  
assert ( is2 : isweq b0 ) . apply ( twooutof3b _ _ ( pr2 a ) is1 ) .  apply ( isweqtotaltofib _ _ _ is2 x ) .   Defined . 

Definition weqhfibersgtof' { X X' Y Z : UU } ( f : X -> Y ) ( f' : X' -> Y ) ( g : Z -> X ) ( g' : Z -> X' ) ( hf : hfsqstr f f' g g' ) ( x : X ) := weqpair _ ( isweqhfibersgtof' _ _ _ _ hf x ) .

Lemma ishfsqweqhfibersgtof' { X X' Y Z : UU } ( f : X -> Y ) ( f' : X' -> Y ) ( g : Z -> X ) ( g' : Z -> X' ) ( h : commsqstr g' f' g f  ) ( is : forall x : X , isweq ( hfibersgtof' f f' g g' h x ) ) :  hfsqstr f f' g g' . 
Proof .  intros . split with h . 
set ( a := weqtococonusf g ) . set ( c0 := commsqZtohfp f f' g g' h ) .  set ( d := weqhfptohfpoverX f f' ) .  set ( b := weqfibtototal _ _ ( fun x : X => weqpair _ ( is x ) ) ) .    
assert ( h1 : forall z : Z , paths ( d ( c0 z ) ) ( b ( a z ) ) ) . intro . simpl .  unfold b . unfold a .   unfold weqtococonusf . unfold tococonusf .   simpl .  unfold totalfun . simpl . assert ( e : paths ( h z ) ( pathscomp0 (h z) (idpath (f (g z))) ) ) . apply ( pathsinv0 ( pathscomp0rid _ ) ) .  induction e .  apply idpath .
assert ( is1 : isweq ( fun z : _ => d ( c0 z ) ) ) . apply ( isweqhomot _ _ ( fun z : Z => ( pathsinv0 ( h1 z ) ) ) ) .   apply ( twooutof3c _ _ ( pr2 a ) ( pr2 b ) ) .  
 apply ( twooutof3a _ _ is1 ( pr2 d ) ) .    Defined .  


Lemma isweqhfibersg'tof { X X' Y Z : UU } ( f : X -> Y ) ( f' : X' -> Y ) ( g : Z -> X ) ( g' : Z -> X' ) ( hf : hfsqstr f f' g g' ) ( x' : X' ) : isweq (  hfibersg'tof f f' g g' hf x' ) . 
Proof. intros . set ( is := pr2 hf ) . set ( h := pr1 hf ) .
set ( a' := weqtococonusf g' ) . set ( c' := weqpair _ is ) .  set ( d' := weqhfptohfpoverX' f f' ) .  set ( b0' := totalfun _ _ ( hfibersg'tof f f' g g' h ) ) .    
assert ( h1 : forall z : Z , paths ( d' ( c' z ) ) ( b0' ( a' z ) ) ) . intro .  unfold b0' . unfold a' .   unfold weqtococonusf . unfold tococonusf .   unfold totalfun . simpl .  assert ( e : paths ( pathsinv0 ( h  z ) ) ( pathscomp0 ( pathsinv0 (h z) ) (idpath (f' (g' z))) ) ) . apply (  pathsinv0 ( pathscomp0rid _ ) ) .  induction e .  apply idpath .
assert ( is1 : isweq ( fun z : _ => b0' ( a' z ) ) ) . apply ( isweqhomot _ _ h1 ) .   apply ( twooutof3c _ _ ( pr2 c' ) ( pr2 d' ) ) .  
assert ( is2 : isweq b0' ) . apply ( twooutof3b _ _ ( pr2 a' ) is1 ) .  apply ( isweqtotaltofib _ _ _ is2 x' ) .   Defined . 

Definition weqhfibersg'tof { X X' Y Z : UU } ( f : X -> Y ) ( f' : X' -> Y ) ( g : Z -> X ) ( g' : Z -> X' ) ( hf : hfsqstr f f' g g' ) ( x' : X' ) := weqpair _ ( isweqhfibersg'tof _ _ _ _ hf x' ) .

Lemma ishfsqweqhfibersg'tof { X X' Y Z : UU } ( f : X -> Y ) ( f' : X' -> Y ) ( g : Z -> X ) ( g' : Z -> X' ) ( h : commsqstr g' f' g f ) ( is : forall x' : X' , isweq ( hfibersg'tof f f' g g' h x' ) ) :  hfsqstr f f' g g' . 
Proof .  intros . split with h . 
set ( a' := weqtococonusf g' ) . set ( c0' := commsqZtohfp f f' g g' h ) .  set ( d' := weqhfptohfpoverX' f f' ) .  set ( b' := weqfibtototal _ _ ( fun x' : X' => weqpair _ ( is x' ) ) ) .    
assert ( h1 : forall z : Z , paths ( d' ( c0' z ) ) ( b' ( a' z ) ) ) . intro . simpl .  unfold b' . unfold a' .   unfold weqtococonusf . unfold tococonusf .   unfold totalfun . simpl . assert ( e : paths ( pathsinv0 ( h z ) ) ( pathscomp0 ( pathsinv0 (h z) ) (idpath (f' (g' z))) ) ) . apply ( pathsinv0 ( pathscomp0rid _ ) ) .  induction e .  apply idpath .
assert ( is1 : isweq ( fun z : _ => d' ( c0' z ) ) ) . apply ( isweqhomot _ _ ( fun z : Z => ( pathsinv0 ( h1 z ) ) ) ) .   apply ( twooutof3c _ _ ( pr2 a' ) ( pr2 b' ) ) .  
 apply ( twooutof3a _ _ is1 ( pr2 d' ) ) .    Defined .  

Theorem transposhfpsqstr { X X' Y Z : UU } ( f : X -> Y ) ( f' : X' -> Y ) ( g : Z -> X ) ( g' : Z -> X' ) ( hf : hfsqstr f f' g g' ) : hfsqstr f' f g' g .
Proof . intros . set ( is := pr2 hf ) . set ( h := pr1 hf ) . set ( th := transposcommsqstr f f' g g' h ) . split with th . 
set ( w1 := weqhfpcomm f f' ) . assert ( h1 : forall z : Z , paths (  w1 ( commsqZtohfp f f' g g' h z ) ) (  commsqZtohfp f' f g' g th z ) ) . intro . unfold commsqZtohfp .  simpl . unfold fpmap . unfold totalfun .   simpl .  apply idpath .  apply ( isweqhomot _ _ h1 ) .  apply ( twooutof3c _ _ is ( pr2 w1 ) ) . Defined . 

    
(** *** Fiber sequences and homotopy fiber squares *)

Theorem fibseqstrtohfsqstr { X Y Z : UU } ( f : X -> Y ) ( g : Y -> Z ) ( z : Z ) ( hf : fibseqstr f g z ) : hfsqstr ( fun t : unit => z ) g ( fun x : X => tt ) f .
Proof . intros . split with ( pr1 hf ) .  set ( ff := ezweq f g z hf ) . set ( ggff := commsqZtohfp ( fun t : unit => z ) g ( fun x : X => tt ) f ( pr1 hf )   ) .  set ( gg := weqhfibertohfp g z ) . 
apply ( pr2 ( weqcomp ff gg ) ) .  Defined . 


Theorem hfsqstrtofibseqstr  { X Y Z : UU } ( f : X -> Y ) ( g : Y -> Z ) ( z : Z ) ( hf :  hfsqstr ( fun t : unit => z ) g ( fun x : X => tt ) f ) : fibseqstr f g z .
Proof . intros . split with ( pr1 hf ) .  set ( ff := ezmap f g z ( pr1 hf ) ) . set ( ggff := weqZtohfp ( fun t : unit => z ) g ( fun x : X => tt ) f hf ) .  set ( gg := weqhfibertohfp g z ) . 
apply ( twooutof3a ff gg ( pr2 ggff ) ( pr2 gg ) ) .  Defined . 

















(* End of the file uu0a.v *)





