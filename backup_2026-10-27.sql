--
-- PostgreSQL database dump
--

\restrict iag9aSpFNQsMUpT5Lnb6LeBcshsfbrQmXTzqk7vvJfC1pIvnlQyF1Ig8d7prt9n

-- Dumped from database version 18.6
-- Dumped by pg_dump version 18.6

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: check_contain_codes(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.check_contain_codes() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF NEW.contain IS NOT NULL AND EXISTS (
    SELECT 1 FROM unnest(NEW.contain) c
    WHERE c NOT IN (SELECT code FROM allergens)
  ) THEN
    RAISE EXCEPTION 'Unknown allergen code in contain: %', NEW.contain;
  END IF;
  RETURN NEW;
END $$;


ALTER FUNCTION public.check_contain_codes() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: allergens; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.allergens (
    code text NOT NULL,
    name text NOT NULL
);


ALTER TABLE public.allergens OWNER TO postgres;

--
-- Name: ingredients; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ingredients (
    code text NOT NULL,
    name text NOT NULL
);


ALTER TABLE public.ingredients OWNER TO postgres;

--
-- Name: items; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.items (
    id integer NOT NULL,
    name text NOT NULL,
    section text NOT NULL,
    contain text[],
    vege boolean DEFAULT false NOT NULL
);


ALTER TABLE public.items OWNER TO postgres;

--
-- Name: items_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.items_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.items_id_seq OWNER TO postgres;

--
-- Name: items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.items_id_seq OWNED BY public.items.id;


--
-- Name: items id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.items ALTER COLUMN id SET DEFAULT nextval('public.items_id_seq'::regclass);


--
-- Data for Name: allergens; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.allergens (code, name) FROM stdin;
NSF	Seafood
NF	Fish
GF	Gluten
ND	Dairy
NS	Shrimp
NRM	Red meat
NP	Pork
Ce	Celery
Ca	Carrot
Ap	Apple
Oil	Oil
Shell	Shell fish
Mu	Mushroom
\.


--
-- Data for Name: ingredients; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ingredients (code, name) FROM stdin;
NSF	Seafood
NF	Fish
GF	Gluten
ND	Dairy
NS	Shrimp
NRM	Red meat
NP	Pork
CE	Celery
CA	Carrot
AP	Apple
OIL	Oil
SHELL	Shell fish
MU	Mushroom
\.


--
-- Data for Name: items; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.items (id, name, section, contain, vege) FROM stdin;
4	Picanha	Churrasco	\N	f
5	Grilled Pineapple	Churrasco	\N	t
6	Grilled Shrimp	Churrasco	\N	f
7	Pork Ribs with BBQ Sauce	Churrasco	\N	f
8	Herb Marinated Mozzarella	Salad Station	\N	f
9	Crispy Shallot Caesar Salad	Salad Station	\N	f
10	Orange	Salad Station	\N	t
11	Buttered Cremini Mushrooms	Warm Food	\N	f
13	Parmesan Alcatra	Churrasco	\N	f
14	Ribeye	Churrasco	\N	f
15	Filet Mignon	Churrasco	\N	f
16	New York Strip Loin	Churrasco	\N	f
17	Maminha	Churrasco	\N	f
18	Fraldinha	Churrasco	\N	f
19	Flank Steak	Churrasco	\N	f
20	Chuck Roll	Churrasco	\N	f
21	Beef Short Ribs	Churrasco	\N	f
22	Wagyu Brisket	Churrasco	\N	f
23	Chimichurri Sauce	Churrasco	\N	f
24	Gaucho Butter Sauce	Churrasco	\N	f
25	Hot Molho de Pimenta	Churrasco	\N	f
27	Pork Belly with Sweet Pepper Sauce	Churrasco	\N	f
28	Chorizo - Pork Sausage	Churrasco	\N	f
29	Lamb Picanha	Churrasco	\N	f
30	Garlic JalapeÃ±o Lamb Rack	Churrasco	\N	f
31	Chicken Breast & Bacon	Churrasco	\N	f
32	Chipotle Chicken Thigh	Churrasco	\N	f
33	Caramelized Chicken Wings	Churrasco	\N	f
34	Chicken Hearts	Churrasco	\N	f
36	Grilled Squid	Churrasco	\N	f
39	Pickled Red Peppers	Antipasto	\N	t
40	Green Bell Peppers	Antipasto	\N	t
41	Green Olives	Antipasto	\N	t
42	Sun-Dried Tomatoes	Antipasto	\N	t
44	Black Bean & Mango Salsa	Salad Station	\N	f
45	Roasted Carrot, Lentil & Feta Salad	Salad Station	\N	f
46	Roasted Pumpkin & Stracciatella Salad	Salad Station	\N	f
48	Tomato, Rocket & Cheese Salad	Salad Station	\N	f
50	Quinoa, Chicken & Kale Salad	Salad Station	\N	f
51	Passion Fruit Chicken Salad	Salad Station	\N	f
52	Herb & Olive Tuna Salad	Salad Station	\N	f
53	Baby Octopus & Cherry Tomato Salad	Salad Station	\N	f
54	Smoked Salmon with Cream Cheese	Salad Station	\N	f
55	JamÃ³n Curado	Charcuterie	\N	f
56	Prosciutto Crudo Stagionato	Charcuterie	\N	f
57	Coppa	Charcuterie	\N	f
58	Milano Salami	Charcuterie	\N	f
59	Salame Napoli	Charcuterie	\N	f
60	Spianata Romana	Charcuterie	\N	f
61	Salame al Tartufo	Charcuterie	\N	f
62	PrÃ©sident Brie	Cheese	\N	f
63	Goat Cheese	Cheese	\N	f
64	Manchego	Cheese	\N	f
65	Parmigiano Reggiano	Cheese	\N	f
66	Blue Cheese	Cheese	\N	f
67	French Fries	Sides & Snacks	\N	f
68	Mandioca Frita	Sides & Snacks	\N	f
69	Fried Sweet Potato	Sides & Snacks	\N	f
70	Feta & Cucumber Bites	CanapÃ©s	\N	f
71	Tuna CanapÃ©	CanapÃ©s	\N	f
72	Parmesan Shrimp Tartlet	CanapÃ©s	\N	f
73	Fig Jam	Bread & Accompaniments	\N	f
74	Raspberry Jam	Bread & Accompaniments	\N	f
75	Bread Selection	Bread & Accompaniments	\N	f
76	Carbonara Butter	Bread & Accompaniments	\N	f
77	Roasted Garlic Butter	Bread & Accompaniments	\N	f
78	Whipped Caesar Butter	Bread & Accompaniments	\N	f
79	Smoky Roasted Eggplant Dip	Bread & Accompaniments	\N	f
80	Cheddar Cheese & JalapeÃ±os	Bread & Accompaniments	\N	f
81	Roasted Red Pepper Hummus	Bread & Accompaniments	\N	f
82	FeijÃ£o Tropeiro	Warm Food	\N	f
83	Moela ao Molho	Warm Food	\N	f
84	Chili Pulled Beef	Warm Food	\N	f
85	Frango na Brasa	Warm Food	\N	f
86	Moqueca da Bahia	Warm Food	\N	f
87	Crispy Garlic Farofa	Warm Food	\N	f
88	Brown Buttered Corn	Warm Food	\N	f
89	Creamy Vegetable Gratin	Warm Food	\N	f
90	FeijÃ£o Carioca com Carne	Warm Food	\N	f
92	Creamy Garlic & Parmesan Pasta	Warm Food	\N	f
93	Herby Olive Oil Roasted Potatoes	Warm Food	\N	f
94	Brazilian Feijoada / Black Bean Stew	Warm Food	\N	f
95	Blue Mussels in Garlic Butter & White Wine	Warm Food	\N	f
96	Arroz ao Alho / Traditional Brazilian Garlic Rice	Warm Food	\N	f
38	Cocktail Cucumbers	Antipasto	{ND,Oil}	t
\.


--
-- Name: items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.items_id_seq', 266, true);


--
-- Name: allergens allergens_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.allergens
    ADD CONSTRAINT allergens_name_key UNIQUE (name);


--
-- Name: allergens allergens_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.allergens
    ADD CONSTRAINT allergens_pkey PRIMARY KEY (code);


--
-- Name: ingredients ingredients_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ingredients
    ADD CONSTRAINT ingredients_name_key UNIQUE (name);


--
-- Name: ingredients ingredients_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ingredients
    ADD CONSTRAINT ingredients_pkey PRIMARY KEY (code);


--
-- Name: items items_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.items
    ADD CONSTRAINT items_name_key UNIQUE (name);


--
-- Name: items items_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.items
    ADD CONSTRAINT items_pkey PRIMARY KEY (id);


--
-- Name: items_contain_gin; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX items_contain_gin ON public.items USING gin (contain);


--
-- Name: items items_check_codes; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER items_check_codes BEFORE INSERT OR UPDATE ON public.items FOR EACH ROW EXECUTE FUNCTION public.check_contain_codes();


--
-- Name: items items_contain_check; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER items_contain_check BEFORE INSERT OR UPDATE ON public.items FOR EACH ROW EXECUTE FUNCTION public.check_contain_codes();


--
-- PostgreSQL database dump complete
--

\unrestrict iag9aSpFNQsMUpT5Lnb6LeBcshsfbrQmXTzqk7vvJfC1pIvnlQyF1Ig8d7prt9n

