--
-- PostgreSQL database dump
--


-- Dumped from database version 15.15 (Debian 15.15-1.pgdg13+1)
-- Dumped by pg_dump version 16.10 (Ubuntu 16.10-0ubuntu0.24.04.1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: set_updated_at(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.set_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
            BEGIN
                NEW.updated_at = NOW();
                RETURN NEW;
            END;
            $$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: category; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.category (
    category_id character varying NOT NULL,
    name character varying NOT NULL,
    description text,
    parent_category_id character varying
);


--
-- Name: energy_context; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.energy_context (
    context_id character varying NOT NULL,
    name character varying NOT NULL,
    description text,
    criticality_level integer NOT NULL,
    CONSTRAINT energy_context_criticality_level_check CHECK (((criticality_level >= 1) AND (criticality_level <= 5)))
);


--
-- Name: risk; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.risk (
    risk_id character varying NOT NULL,
    status character varying,
    version character varying,
    card jsonb NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: risk_category; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.risk_category (
    risk_id character varying NOT NULL,
    category_id character varying NOT NULL,
    assignment_type character varying NOT NULL,
    CONSTRAINT chk_assignment_type CHECK (((assignment_type)::text <> ''::text))
);


--
-- Name: risk_context; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.risk_context (
    risk_id character varying NOT NULL,
    context_id character varying NOT NULL,
    exposure_level integer NOT NULL,
    CONSTRAINT chk_exposure_level CHECK (((exposure_level >= 1) AND (exposure_level <= 5)))
);


--
-- Data for Name: category; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.category (category_id, name, description, parent_category_id) VALUES ('technical.attack', 'Technical Attack', 'Adversarial or malicious technical actions against AI systems.', NULL);
INSERT INTO public.category (category_id, name, description, parent_category_id) VALUES ('governance.oversight', 'Governance Oversight', 'Oversight and accountability gaps in AI operations.', NULL);
INSERT INTO public.category (category_id, name, description, parent_category_id) VALUES ('governance.fairness', 'Governance Fairness', 'Equity, bias, or fairness risks within AI governance.', NULL);
INSERT INTO public.category (category_id, name, description, parent_category_id) VALUES ('governance.monitoring', 'Governance Monitoring', 'Monitoring and performance management risks for AI systems.', NULL);
INSERT INTO public.category (category_id, name, description, parent_category_id) VALUES ('governance.transparency', 'Governance Transparency', 'Transparency, explainability, or stakeholder communication risks.', NULL);
INSERT INTO public.category (category_id, name, description, parent_category_id) VALUES ('governance.compliance', 'Governance Compliance', 'Regulatory reporting, documentation, or compliance gaps.', NULL);
INSERT INTO public.category (category_id, name, description, parent_category_id) VALUES ('governance.legal', 'Governance Legal', 'Legal exposure and contractual obligations tied to AI usage.', NULL);
INSERT INTO public.category (category_id, name, description, parent_category_id) VALUES ('privacy.governance', 'Privacy Governance', 'Privacy and data protection issues in AI governance.', NULL);
INSERT INTO public.category (category_id, name, description, parent_category_id) VALUES ('safety.incidents', 'Safety Incidents', 'Documented AI-related safety or operational incidents.', NULL);


--
-- Data for Name: energy_context; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.energy_context (context_id, name, description, criticality_level) VALUES ('generation_renewables', 'Renewable Generation', 'Solar, wind, hydro, or other renewable generation assets.', 3);
INSERT INTO public.energy_context (context_id, name, description, criticality_level) VALUES ('generation_conventional', 'Conventional Generation', 'Thermal, nuclear, or fossil-based power plants.', 3);
INSERT INTO public.energy_context (context_id, name, description, criticality_level) VALUES ('transmission_control', 'Transmission Control', 'Transmission network operations, substations, relay protection.', 4);
INSERT INTO public.energy_context (context_id, name, description, criticality_level) VALUES ('distribution_operations', 'Distribution Operations', 'Distribution management systems, outage restoration, voltage regulation.', 3);
INSERT INTO public.energy_context (context_id, name, description, criticality_level) VALUES ('market_operations', 'Market Operations', 'Trading, dispatch optimisation, balancing markets, price forecasting.', 3);
INSERT INTO public.energy_context (context_id, name, description, criticality_level) VALUES ('demand_response', 'Demand Response', 'Flexibility management, demand response aggregators, prosumer programmes.', 3);
INSERT INTO public.energy_context (context_id, name, description, criticality_level) VALUES ('retail_energy', 'Retail Energy', 'Customer-facing services, billing, personalisation, demand prediction.', 2);
INSERT INTO public.energy_context (context_id, name, description, criticality_level) VALUES ('enterprise_it', 'Enterprise IT', 'Back-office AI (HR, cybersecurity, procurement, document processing).', 2);
INSERT INTO public.energy_context (context_id, name, description, criticality_level) VALUES ('asset_management', 'Asset Management', 'Predictive maintenance, inspection drones, fault detection.', 3);
INSERT INTO public.energy_context (context_id, name, description, criticality_level) VALUES ('public_affairs', 'Public Affairs', 'External communications, regulatory transparency, explainability obligations.', 2);
INSERT INTO public.energy_context (context_id, name, description, criticality_level) VALUES ('legal_affairs', 'Legal Affairs', 'Compliance tracking, documentation, regulatory submissions.', 2);
INSERT INTO public.energy_context (context_id, name, description, criticality_level) VALUES ('supply_chain', 'Supply Chain', 'Vendor data, model sourcing, and third-party dependencies.', 3);
INSERT INTO public.energy_context (context_id, name, description, criticality_level) VALUES ('control_rooms', 'Control Rooms', 'Real-time supervision, operator decision support, human-AI teaming.', 4);
INSERT INTO public.energy_context (context_id, name, description, criticality_level) VALUES ('transmission_planning', 'Transmission Planning', 'Grid expansion, capacity planning, load flow simulations.', 3);
INSERT INTO public.energy_context (context_id, name, description, criticality_level) VALUES ('distributed_generation', 'Distributed Generation', 'DER forecasting, microgrids, and virtual power plants.', 3);
INSERT INTO public.energy_context (context_id, name, description, criticality_level) VALUES ('substation_security', 'Substation Security', 'Physical and digital security, surveillance analytics.', 4);


--
-- Data for Name: risk; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.risk (risk_id, status, version, card, created_at, updated_at) VALUES ('EG-R-0001', 'seeded', '1.0', '{"version": "1.0", "risk_name": "Training Data Poisoning", "stable_id": "EG-R-0001", "categories": ["technical.attack"], "merge_hash": "43e75f7992a010df09c44b810b8402b76fb86612b1c55e12b3c45440fd059383", "provenance": [{"action": "merged", "sources": ["MITRE_ATLAS:AML.T0020"]}, {"aiid": "INC-1023", "date": "2024-03-01", "editor": "ICCS", "mit_airisk": "data-integrity"}, {"action": "create", "editor": "ICCS", "timestamp": "2025-11-24T16:54:38.920928"}], "description": "Adversaries inject malicious samples into training pipelines for forecasting models, leading to skewed predictions and unreliable dispatch guidance.", "impact_level": 5, "risk_summary": "Adversaries inject malicious samples into training pipelines for forecasting models, leading to skewed predictions and unreliable dispatch guidance.", "ai_model_type": ["deep_learning", "forecasting"], "related_risks": ["EG-R-0003", "EG-R-0014", "EG-R-0015"], "energy_context": ["transmission_control"], "lifecycle_stage": "training", "source_reference": ["AIID:INC-1023", "MIT_AIRISK:data-integrity", "MITRE_ATLAS:AML.T0020"], "impact_dimensions": ["reliability", "safety"], "known_mitigations": ["Data validation", "supplier vetting"], "probability_level": 3, "trigger_conditions": "Compromised data supply chain for model retraining", "operational_priority": 5, "regulatory_requirements": ["EU-AI-Act-TitleIV", "NERC-CIP-013"], "technological_dependencies": ["Data labeling platforms", "ETL pipelines"]}', '2025-11-24 16:54:38.913705', '2025-11-24 16:54:38.913705');
INSERT INTO public.risk (risk_id, status, version, card, created_at, updated_at) VALUES ('EG-R-0002', 'seeded', '1.0', '{"version": "1.0", "risk_name": "Adversarial Evasion on Protective Relays", "stable_id": "EG-R-0002", "categories": ["technical.attack"], "merge_hash": "370c0f2c9460cb7bcc0f5bd50c71b73244735c583a672914a2b2f0df05424850", "provenance": [{"action": "merged", "sources": ["MITRE_ATLAS:AML.T0043"]}, {"aiid": "INC-0875", "date": "2024-03-01", "editor": "ICCS"}, {"action": "create", "editor": "ICCS", "timestamp": "2025-11-24T16:54:38.933840"}], "description": "Adversarial perturbations targeting sensor inputs cause misclassification of fault conditions, bypassing automated trip logic.", "impact_level": 5, "risk_summary": "Adversarial perturbations targeting sensor inputs cause misclassification of fault conditions, bypassing automated trip logic.", "ai_model_type": ["control", "deep_learning"], "related_risks": ["EG-R-0017"], "energy_context": ["transmission_control"], "lifecycle_stage": "deployment", "source_reference": ["AIID:INC-0875", "MITRE_ATLAS:AML.T0043"], "impact_dimensions": ["reliability", "safety"], "known_mitigations": ["Adversarial training", "signal authentication"], "probability_level": 2, "trigger_conditions": "Malicious waveform injection at substation PMUs", "operational_priority": 5, "regulatory_requirements": ["IEC-61850", "NERC-PRC-005"], "technological_dependencies": ["edge accelerators", "Real-time monitoring"]}', '2025-11-24 16:54:38.913705', '2025-11-24 16:54:38.913705');
INSERT INTO public.risk (risk_id, status, version, card, created_at, updated_at) VALUES ('EG-R-0003', 'seeded', '1.0', '{"version": "1.0", "risk_name": "Model Backdoor Activation", "stable_id": "EG-R-0003", "categories": ["technical.attack"], "merge_hash": "56cd019c35a6c09be39deaa0fe35d11ae00dc1c614d0afaf196d044b985f7432", "provenance": [{"action": "merged", "sources": ["MITRE_ATLAS:AML.T0043.004"]}, {"aiid": "INC-1042", "date": "2024-03-02", "editor": "ICCS"}, {"action": "create", "editor": "ICCS", "timestamp": "2025-11-24T16:54:38.943219"}], "description": "Hidden triggers inserted during model training activate malicious behaviors when specific patterns appear in telemetry.", "impact_level": 5, "risk_summary": "Hidden triggers inserted during model training activate malicious behaviors when specific patterns appear in telemetry.", "ai_model_type": ["deep_learning"], "related_risks": ["EG-R-0001"], "energy_context": ["distribution_operations"], "lifecycle_stage": "training", "source_reference": ["AIID:INC-1042", "MITRE_ATLAS:AML.T0043.004"], "impact_dimensions": ["safety", "security"], "known_mitigations": ["adversarial scanning", "Weight provenance checks"], "probability_level": 2, "trigger_conditions": "Tampered pretrained weights delivered through vendor updates", "operational_priority": 4, "regulatory_requirements": ["DOE-CIP-Guidance", "NIST-800-53"], "technological_dependencies": ["MLOps pipelines", "Model registries"]}', '2025-11-24 16:54:38.913705', '2025-11-24 16:54:38.913705');
INSERT INTO public.risk (risk_id, status, version, card, created_at, updated_at) VALUES ('EG-R-0004', 'seeded', '1.0', '{"version": "1.0", "risk_name": "Model Inversion Privacy Leak", "stable_id": "EG-R-0004", "categories": ["privacy.governance"], "merge_hash": "dcfb752a58004ec6588ecf20705b462a4e2c1472694cdfbabe87ef734db867e0", "provenance": [{"action": "merged", "sources": ["MITRE_ATLAS:AML.T0024.001"]}, {"aiid": "INC-0661", "date": "2024-03-02", "editor": "ICCS"}, {"action": "create", "editor": "ICCS", "timestamp": "2025-11-24T16:54:38.949031"}], "description": "Attackers reconstruct sensitive training data from forecasting models, exposing customer usage profiles.", "impact_level": 4, "risk_summary": "Attackers reconstruct sensitive training data from forecasting models, exposing customer usage profiles.", "ai_model_type": ["forecasting"], "related_risks": ["EG-R-0005", "EG-R-0022"], "energy_context": ["retail_energy"], "lifecycle_stage": "governance", "source_reference": ["AIID:INC-0661", "MITRE_ATLAS:AML.T0024.001"], "impact_dimensions": ["privacy", "reputation"], "known_mitigations": ["Differential privacy", "query throttling"], "probability_level": 3, "trigger_conditions": "Overexposed inference API with unrestricted queries", "operational_priority": 4, "regulatory_requirements": ["EU-GDPR", "US-CCPA"], "technological_dependencies": ["Cloud inference endpoints", "usage databases"]}', '2025-11-24 16:54:38.913705', '2025-11-24 16:54:38.913705');
INSERT INTO public.risk (risk_id, status, version, card, created_at, updated_at) VALUES ('EG-R-0005', 'seeded', '1.0', '{"version": "1.0", "risk_name": "Membership Inference on DER Forecasts", "stable_id": "EG-R-0005", "categories": ["privacy.governance"], "merge_hash": "2fc0c105336677c3626b9c2af7ae02d434c04b47a2d8a120508b18275edc56f1", "provenance": [{"action": "merged", "sources": ["MITRE_ATLAS:AML.T0024.000"]}, {"aiid": "INC-0543", "date": "2024-03-03", "editor": "ICCS"}, {"action": "create", "editor": "ICCS", "timestamp": "2025-11-24T16:54:38.954541"}], "description": "Malicious actors infer which distributed energy resources contributed to a model by analyzing prediction outputs.", "impact_level": 4, "risk_summary": "Malicious actors infer which distributed energy resources contributed to a model by analyzing prediction outputs.", "ai_model_type": ["forecasting", "optimization"], "related_risks": ["EG-R-0004", "EG-R-0006"], "energy_context": ["distributed_generation"], "lifecycle_stage": "governance", "source_reference": ["AIID:INC-0543", "MITRE_ATLAS:AML.T0024.000"], "impact_dimensions": ["privacy", "reliability"], "known_mitigations": ["access control", "Differential privacy"], "probability_level": 3, "trigger_conditions": "Bulk query of public API combined with auxiliary datasets", "operational_priority": 3, "regulatory_requirements": ["DOE-Data-Privacy-Order", "EU-GDPR"], "technological_dependencies": ["analytics stacks", "Cloud orchestration"]}', '2025-11-24 16:54:38.913705', '2025-11-24 16:54:38.913705');
INSERT INTO public.risk (risk_id, status, version, card, created_at, updated_at) VALUES ('EG-R-0006', 'seeded', '1.0', '{"version": "1.0", "risk_name": "Model Extraction Theft", "stable_id": "EG-R-0006", "categories": ["governance.legal"], "merge_hash": "d4cad5e0394eb93dbdf1091799c55b5b2660b2117691e9b24f29a98b791edd35", "provenance": [{"action": "merged", "sources": ["MITRE_ATLAS:AML.T0024.002"]}, {"aiid": "INC-0332", "date": "2024-03-04", "editor": "ICCS"}, {"action": "create", "editor": "ICCS", "timestamp": "2025-11-24T16:54:38.962041"}], "description": "Attackers replicate proprietary dispatch optimization models by adaptive querying, eroding competitive advantage.", "impact_level": 3, "risk_summary": "Attackers replicate proprietary dispatch optimization models by adaptive querying, eroding competitive advantage.", "ai_model_type": ["optimization"], "related_risks": ["EG-R-0005", "EG-R-0016"], "energy_context": ["market_operations"], "lifecycle_stage": "governance", "source_reference": ["AIID:INC-0332", "MITRE_ATLAS:AML.T0024.002"], "impact_dimensions": ["financial", "reputation"], "known_mitigations": ["Rate limiting", "watermarking"], "probability_level": 2, "trigger_conditions": "High-volume query campaigns with synthetic load profiles", "operational_priority": 3, "regulatory_requirements": ["EU-AI-Act-Art53", "US-TRADE-SECRETS-ACT"], "technological_dependencies": ["API gateways", "optimization engines"]}', '2025-11-24 16:54:38.913705', '2025-11-24 16:54:38.913705');
INSERT INTO public.risk (risk_id, status, version, card, created_at, updated_at) VALUES ('EG-R-0007', 'seeded', '1.0', '{"version": "1.0", "risk_name": "Operational Automation Bias", "stable_id": "EG-R-0007", "categories": ["governance.oversight"], "merge_hash": "5f1053aa4c179dcc540927fb58e592f848f8bb488b7909b4ef67b716dc7b3d2b", "provenance": [{"action": "merged", "sources": ["MIT_AIRISK:automation-bias"]}, {"aiid": "INC-0214", "date": "2024-03-05", "editor": "FORA"}, {"action": "create", "editor": "ICCS", "timestamp": "2025-11-24T16:54:38.968591"}], "description": "Operators over-trust AI dispatch recommendations despite conflicting sensor evidence, leading to delayed corrective actions.", "impact_level": 4, "risk_summary": "Operators over-trust AI dispatch recommendations despite conflicting sensor evidence, leading to delayed corrective actions.", "ai_model_type": ["expert_systems", "forecasting"], "related_risks": ["EG-R-0008", "EG-R-0012"], "energy_context": ["control_rooms"], "lifecycle_stage": "governance", "source_reference": ["AIID:INC-0214", "MIT_AIRISK:automation-bias"], "impact_dimensions": ["operational", "safety"], "known_mitigations": ["alerting standards", "Human-in-the-loop drills"], "probability_level": 4, "trigger_conditions": "Absence of counterfactual explanations during high load events", "operational_priority": 4, "regulatory_requirements": ["EU-AI-Act-TitleIII", "NERC-EOP-005"], "technological_dependencies": ["recommendation engines", "Visualization dashboards"]}', '2025-11-24 16:54:38.913705', '2025-11-24 16:54:38.913705');
INSERT INTO public.risk (risk_id, status, version, card, created_at, updated_at) VALUES ('EG-R-0008', 'seeded', '1.0', '{"version": "1.0", "risk_name": "Inadequate Human Oversight", "stable_id": "EG-R-0008", "categories": ["governance.oversight"], "merge_hash": "ce91484939089edf1c85072082b33aee497106c7de994a7d23df937412e9970d", "provenance": [{"action": "merged", "sources": ["MIT_AIRISK:human-oversight"]}, {"aiid": "INC-0654", "date": "2024-03-05", "editor": "FORA"}, {"action": "create", "editor": "ICCS", "timestamp": "2025-11-24T16:54:38.975678"}], "description": "No clear escalation path for overriding AI control decisions causing cascading failures during voltage excursions.", "impact_level": 5, "risk_summary": "No clear escalation path for overriding AI control decisions causing cascading failures during voltage excursions.", "ai_model_type": ["control", "reinforcement_learning"], "related_risks": ["EG-R-0007", "EG-R-0009", "EG-R-0013"], "energy_context": ["control_rooms"], "lifecycle_stage": "governance", "source_reference": ["AIID:INC-0654", "MIT_AIRISK:human-oversight"], "impact_dimensions": ["compliance", "safety"], "known_mitigations": ["Defined override roles", "periodic manual drills"], "probability_level": 3, "trigger_conditions": "Lack of override authority during autonomous control operations", "operational_priority": 5, "regulatory_requirements": ["EU-AI-Act-Art14", "NERC-PER-005"], "technological_dependencies": ["policy engines", "Supervisory control systems"]}', '2025-11-24 16:54:38.913705', '2025-11-24 16:54:38.913705');
INSERT INTO public.risk (risk_id, status, version, card, created_at, updated_at) VALUES ('EG-R-0009', 'seeded', '1.0', '{"version": "1.0", "risk_name": "Goal Mis-specification", "stable_id": "EG-R-0009", "categories": ["governance.oversight"], "merge_hash": "311b2780d00a9671ba1aa4e1b4f05aae80ec45ad2c0fe4ce330deffcb3ef4c07", "provenance": [{"action": "merged", "sources": ["MIT_AIRISK:goal-misspecification"]}, {"aiid": "INC-0720", "date": "2024-03-06", "editor": "FORA"}, {"action": "create", "editor": "ICCS", "timestamp": "2025-11-24T16:54:38.981963"}], "description": "AI optimizer minimizes cost at expense of reserve margins, compromising reliability under peak stress.", "impact_level": 5, "risk_summary": "AI optimizer minimizes cost at expense of reserve margins, compromising reliability under peak stress.", "ai_model_type": ["optimization", "reinforcement_learning"], "related_risks": ["EG-R-0008", "EG-R-0010"], "energy_context": ["market_operations"], "lifecycle_stage": "governance", "source_reference": ["AIID:INC-0720", "MIT_AIRISK:goal-misspecification"], "impact_dimensions": ["reliability", "safety"], "known_mitigations": ["multi-objective KPIs", "Reward shaping"], "probability_level": 3, "trigger_conditions": "Poorly defined reward function lacking safety penalties", "operational_priority": 5, "regulatory_requirements": ["EU-AI-Act-Art9", "FERC-Order-2222"], "technological_dependencies": ["market data feeds", "Optimization solvers"]}', '2025-11-24 16:54:38.913705', '2025-11-24 16:54:38.913705');
INSERT INTO public.risk (risk_id, status, version, card, created_at, updated_at) VALUES ('EG-R-0010', 'seeded', '1.0', '{"version": "1.0", "risk_name": "Insufficient Monitoring and Drift", "stable_id": "EG-R-0010", "categories": ["governance.monitoring"], "merge_hash": "06ba4d19fc4007701566b24574f07c777f5934a5b1d534ce2524ca0669081f0d", "provenance": [{"action": "merged", "sources": ["MIT_AIRISK:monitoring-drift"]}, {"aiid": "INC-0488", "date": "2024-03-06", "editor": "FORA"}, {"action": "create", "editor": "ICCS", "timestamp": "2025-11-24T16:54:38.988205"}], "description": "Model degradation under new weather regimes causes inaccurate load forecasts and scheduling mismatches.", "impact_level": 4, "risk_summary": "Model degradation under new weather regimes causes inaccurate load forecasts and scheduling mismatches.", "ai_model_type": ["forecasting"], "related_risks": ["EG-R-0009", "EG-R-0018", "EG-R-0024"], "energy_context": ["transmission_planning"], "lifecycle_stage": "monitoring", "source_reference": ["AIID:INC-0488", "MIT_AIRISK:monitoring-drift"], "impact_dimensions": ["financial", "reliability"], "known_mitigations": ["Continuous monitoring", "shadow deployments"], "probability_level": 4, "trigger_conditions": "Lack of post-deployment monitoring for data drift", "operational_priority": 4, "regulatory_requirements": ["EU-AI-Act-Art15", "NERC-MOD-033"], "technological_dependencies": ["MLOps observability", "telemetry warehouses"]}', '2025-11-24 16:54:38.913705', '2025-11-24 16:54:38.913705');
INSERT INTO public.risk (risk_id, status, version, card, created_at, updated_at) VALUES ('EG-R-0011', 'seeded', '1.0', '{"version": "1.0", "risk_name": "Bias in Load Forecasting", "stable_id": "EG-R-0011", "categories": ["governance.fairness"], "merge_hash": "684b3e49eb2a91bfe9afeee04c0635dca758d8f37d9be9f164f149ea3adc3934", "provenance": [{"action": "merged", "sources": ["MIT_AIRISK:governance-bias"]}, {"aiid": "INC-0133", "date": "2024-03-07", "editor": "FORA"}, {"action": "create", "editor": "ICCS", "timestamp": "2025-11-24T16:54:38.995469"}], "description": "Systematic under-forecasting for specific communities drives inequitable outage risks during restoration.", "impact_level": 4, "risk_summary": "Systematic under-forecasting for specific communities drives inequitable outage risks during restoration.", "ai_model_type": ["forecasting"], "related_risks": ["EG-R-0012", "EG-R-0013"], "energy_context": ["distribution_operations"], "lifecycle_stage": "governance", "source_reference": ["AIID:INC-0133", "MIT_AIRISK:governance-bias"], "impact_dimensions": ["fairness"], "known_mitigations": ["Bias audits", "data augmentation"], "probability_level": 3, "trigger_conditions": "Biased historical data lacking demographic adjustments", "operational_priority": 4, "regulatory_requirements": ["EU-AI-Act-TitleIV", "US-EO-14008"], "technological_dependencies": ["data lakes", "Forecasting pipelines"]}', '2025-11-24 16:54:38.913705', '2025-11-24 16:54:38.913705');
INSERT INTO public.risk (risk_id, status, version, card, created_at, updated_at) VALUES ('EG-R-0012', 'seeded', '1.0', '{"version": "1.0", "risk_name": "Lack of Transparency", "stable_id": "EG-R-0012", "categories": ["governance.transparency"], "merge_hash": "40811324a284ddf0422bed8566f301d1c39cd1705017e5581a647c9e2943a34c", "provenance": [{"action": "merged", "sources": ["MIT_AIRISK:transparency"]}, {"aiid": "INC-0982", "date": "2024-03-07", "editor": "FORA"}, {"action": "create", "editor": "ICCS", "timestamp": "2025-11-24T16:54:39.002057"}], "description": "Opaque AI-driven outage prioritization erodes public trust and complicates regulatory reporting.", "impact_level": 3, "risk_summary": "Opaque AI-driven outage prioritization erodes public trust and complicates regulatory reporting.", "ai_model_type": ["expert_systems", "forecasting"], "related_risks": ["EG-R-0007", "EG-R-0011", "EG-R-0019"], "energy_context": ["public_affairs"], "lifecycle_stage": "governance", "source_reference": ["AIID:INC-0982", "MIT_AIRISK:transparency"], "impact_dimensions": ["compliance", "reputation"], "known_mitigations": ["Explainable AI dashboards", "regulatory briefings"], "probability_level": 3, "trigger_conditions": "Proprietary models without explainability artifacts", "operational_priority": 3, "regulatory_requirements": ["EU-AI-Act-Art13", "STATE-UTILITY-COMMISSION-ORDERS"], "technological_dependencies": ["Decision support tools", "reporting systems"]}', '2025-11-24 16:54:38.913705', '2025-11-24 16:54:38.913705');
INSERT INTO public.risk (risk_id, status, version, card, created_at, updated_at) VALUES ('EG-R-0013', 'seeded', '1.0', '{"version": "1.0", "risk_name": "Overreliance on Automation", "stable_id": "EG-R-0013", "categories": ["governance.oversight"], "merge_hash": "fd5c52d876c98440cb299d629a1df9b11fb5d2951ead992b5aaa79d7d423192c", "provenance": [{"action": "merged", "sources": ["MIT_AIRISK:automation-bias"]}, {"aiid": "INC-0777", "date": "2024-03-08", "editor": "FORA"}, {"action": "create", "editor": "ICCS", "timestamp": "2025-11-24T16:54:39.008555"}], "description": "Operators defer to AI alarms despite contradictory field reports during storm restoration.", "impact_level": 4, "risk_summary": "Operators defer to AI alarms despite contradictory field reports during storm restoration.", "ai_model_type": ["expert_systems"], "related_risks": ["EG-R-0008", "EG-R-0011", "EG-R-0023"], "energy_context": ["distribution_operations"], "lifecycle_stage": "governance", "source_reference": ["AIID:INC-0777", "MIT_AIRISK:automation-bias"], "impact_dimensions": ["operational", "safety"], "known_mitigations": ["clear escalation rules", "Human factors training"], "probability_level": 4, "trigger_conditions": "High alert fatigue and missing context for overrides", "operational_priority": 4, "regulatory_requirements": ["EU-AI-Act-Art14", "OSHA-29CFR-1910"], "technological_dependencies": ["Incident management platforms", "mobile apps"]}', '2025-11-24 16:54:38.913705', '2025-11-24 16:54:38.913705');
INSERT INTO public.risk (risk_id, status, version, card, created_at, updated_at) VALUES ('EG-R-0014', 'seeded', '1.0', '{"version": "1.0", "risk_name": "Insider Data Poisoning", "stable_id": "EG-R-0014", "categories": ["technical.attack"], "merge_hash": "18b963dd85e786fa6b921ca054519cf8d4e6e1441f6d7e899e67e679484d188e", "provenance": [{"action": "merged", "sources": ["MITRE_ATLAS:AML.T0020"]}, {"aiid": "INC-1099", "date": "2024-03-09", "editor": "ICCS"}, {"action": "create", "editor": "ICCS", "timestamp": "2025-11-24T16:54:39.016147"}], "description": "Privileged contractor alters sensor calibration files prior to training updates, biasing state estimation.", "impact_level": 4, "risk_summary": "Privileged contractor alters sensor calibration files prior to training updates, biasing state estimation.", "ai_model_type": ["deep_learning", "state_estimation"], "related_risks": ["EG-R-0001"], "energy_context": ["transmission_control"], "lifecycle_stage": "training", "source_reference": ["AIID:INC-1099", "MITRE_ATLAS:AML.T0020"], "impact_dimensions": ["safety", "security"], "known_mitigations": ["Code reviews", "dual control"], "probability_level": 2, "trigger_conditions": "Unauthorized modification to calibration repository", "operational_priority": 4, "regulatory_requirements": ["NERC-CIP-007", "SOX-ITGC"], "technological_dependencies": ["SCADA gateways", "Version control systems"]}', '2025-11-24 16:54:38.913705', '2025-11-24 16:54:38.913705');
INSERT INTO public.risk (risk_id, status, version, card, created_at, updated_at) VALUES ('EG-R-0015', 'seeded', '1.0', '{"version": "1.0", "risk_name": "Supplier Pipeline Poisoning", "stable_id": "EG-R-0015", "categories": ["technical.attack"], "merge_hash": "e8d3f2c7cc0c4d3307e79fd7782b1293b8cc5b3c564458be89feb654d96c7c05", "provenance": [{"action": "merged", "sources": ["MITRE_ATLAS:AML.T0020"]}, {"date": "2024-03-09", "editor": "ICCS", "mit_airisk": "supply-chain"}, {"action": "create", "editor": "ICCS", "timestamp": "2025-11-24T16:54:39.024607"}], "description": "Third-party dataset vendor delivers manipulated renewable output histories impacting optimization accuracy.", "impact_level": 4, "risk_summary": "Third-party dataset vendor delivers manipulated renewable output histories impacting optimization accuracy.", "ai_model_type": ["forecasting", "optimization"], "related_risks": ["EG-R-0001"], "energy_context": ["supply_chain"], "lifecycle_stage": "training", "source_reference": ["MIT_AIRISK:supply-chain", "MITRE_ATLAS:AML.T0020"], "impact_dimensions": ["financial", "reliability"], "known_mitigations": ["cryptographic signing", "Supplier assurance"], "probability_level": 3, "trigger_conditions": "Compromised supplier download channel", "operational_priority": 4, "regulatory_requirements": ["ISO-27036", "NERC-CIP-013"], "technological_dependencies": ["data brokers", "Vendor APIs"]}', '2025-11-24 16:54:38.913705', '2025-11-24 16:54:38.913705');
INSERT INTO public.risk (risk_id, status, version, card, created_at, updated_at) VALUES ('EG-R-0016', 'seeded', '1.0', '{"version": "1.0", "risk_name": "Insecure Model Release", "stable_id": "EG-R-0016", "categories": ["technical.attack"], "merge_hash": "5b2d4e166c88bd0fc45673740db64573b8b9088812722377c6d70d4553350df9", "provenance": [{"action": "merged", "sources": ["MITRE_ATLAS:AML.T0044"]}, {"aiid": "INC-0622", "date": "2024-03-10", "editor": "ICCS"}, {"action": "create", "editor": "ICCS", "timestamp": "2025-11-24T16:54:39.031922"}], "description": "Leaked model artifacts allow adversaries to reverse engineer dispatch strategies.", "impact_level": 3, "risk_summary": "Leaked model artifacts allow adversaries to reverse engineer dispatch strategies.", "ai_model_type": ["deep_learning", "optimization"], "related_risks": ["EG-R-0006"], "energy_context": ["enterprise_it"], "lifecycle_stage": "deployment", "source_reference": ["AIID:INC-0622", "MITRE_ATLAS:AML.T0044"], "impact_dimensions": ["financial", "security"], "known_mitigations": ["Access control hardening", "encryption"], "probability_level": 2, "trigger_conditions": "Improper access controls on model registry exports", "operational_priority": 3, "regulatory_requirements": ["NERC-CIP-004", "NIST-800-53"], "technological_dependencies": ["artifact stores", "Model registries"]}', '2025-11-24 16:54:38.913705', '2025-11-24 16:54:38.913705');
INSERT INTO public.risk (risk_id, status, version, card, created_at, updated_at) VALUES ('EG-R-0017', 'seeded', '1.0', '{"version": "1.0", "risk_name": "Real-Time Sensor Spoofing", "stable_id": "EG-R-0017", "categories": ["technical.attack"], "merge_hash": "adf881a7c804bca0cd9128fa6c2c7b3e4f2961ce28b05c282fd536e54a9e0c09", "provenance": [{"action": "merged", "sources": ["MITRE_ATLAS:AML.T0016.000"]}, {"aiid": "INC-0401", "date": "2024-03-10", "editor": "ICCS"}, {"action": "create", "editor": "ICCS", "timestamp": "2025-11-24T16:54:39.039832"}], "description": "Attackers replay stale PMU data causing incorrect load-shed instructions by AI-based stability tools.", "impact_level": 5, "risk_summary": "Attackers replay stale PMU data causing incorrect load-shed instructions by AI-based stability tools.", "ai_model_type": ["control", "deep_learning"], "related_risks": ["EG-R-0002"], "energy_context": ["transmission_control"], "lifecycle_stage": "deployment", "source_reference": ["AIID:INC-0401", "MITRE_ATLAS:AML.T0016.000"], "impact_dimensions": ["reliability", "safety"], "known_mitigations": ["redundant sensing", "Secure sync"], "probability_level": 3, "trigger_conditions": "Compromised network segment at substation", "operational_priority": 5, "regulatory_requirements": ["IEC-60870-5-104", "NERC-CIP-005"], "technological_dependencies": ["edge controllers", "PMUs"]}', '2025-11-24 16:54:38.913705', '2025-11-24 16:54:38.913705');
INSERT INTO public.risk (risk_id, status, version, card, created_at, updated_at) VALUES ('EG-R-0018', 'seeded', '1.0', '{"version": "1.0", "risk_name": "Backoffice Model Drift", "stable_id": "EG-R-0018", "categories": ["governance.monitoring"], "merge_hash": "1925c7c683770e427a24e655325d87ebc09dc33355bdfb4ad7070c5a7c4ddd87", "provenance": [{"action": "merged", "sources": ["MIT_AIRISK:monitoring-drift"]}, {"aiid": "INC-0885", "date": "2024-03-11", "editor": "FORA"}, {"action": "create", "editor": "ICCS", "timestamp": "2025-11-24T16:54:39.046126"}], "description": "Customer churn prediction drifts leading to mis-targeted retention incentives affecting revenue stability.", "impact_level": 3, "risk_summary": "Customer churn prediction drifts leading to mis-targeted retention incentives affecting revenue stability.", "ai_model_type": ["classification", "machine_learning"], "related_risks": ["EG-R-0010"], "energy_context": ["retail_energy"], "lifecycle_stage": "monitoring", "source_reference": ["AIID:INC-0885", "MIT_AIRISK:monitoring-drift"], "impact_dimensions": ["financial", "reputation"], "known_mitigations": ["model governance", "Regular retraining"], "probability_level": 4, "trigger_conditions": "Changing customer behavior without retraining cadence", "operational_priority": 3, "regulatory_requirements": ["EU-GDPR", "SEC-Fair-Disclosure"], "technological_dependencies": ["CRM systems", "data lakes"]}', '2025-11-24 16:54:38.913705', '2025-11-24 16:54:38.913705');
INSERT INTO public.risk (risk_id, status, version, card, created_at, updated_at) VALUES ('EG-R-0019', 'seeded', '1.0', '{"version": "1.0", "risk_name": "Regulatory Non-Compliance Tracking", "stable_id": "EG-R-0019", "categories": ["governance.compliance"], "merge_hash": "88d4cab78d7c74d45c13b3bc0264e736cf347731de703f7bc525855b76906a19", "provenance": [{"action": "merged", "sources": ["MIT_AIRISK:compliance-tracking"]}, {"aiid": "INC-0320", "date": "2024-03-11", "editor": "HAL"}, {"action": "create", "editor": "ICCS", "timestamp": "2025-11-24T16:54:39.052903"}], "description": "AI assistant misclassifies regulatory filings deadlines leading to missed compliance milestones.", "impact_level": 3, "risk_summary": "AI assistant misclassifies regulatory filings deadlines leading to missed compliance milestones.", "ai_model_type": ["expert_systems", "nlp"], "related_risks": ["EG-R-0012", "EG-R-0020", "EG-R-0021"], "energy_context": ["legal_affairs"], "lifecycle_stage": "governance", "source_reference": ["AIID:INC-0320", "MIT_AIRISK:compliance-tracking"], "impact_dimensions": ["compliance", "reputation"], "known_mitigations": ["compliance calendars", "Human validation checkpoints"], "probability_level": 3, "trigger_conditions": "Ambiguous policy language without validation", "operational_priority": 3, "regulatory_requirements": ["EU-AI-Act-TitleIX", "FERC-Filing-Mandates"], "technological_dependencies": ["Document understanding", "workflow tools"]}', '2025-11-24 16:54:38.913705', '2025-11-24 16:54:38.913705');
INSERT INTO public.risk (risk_id, status, version, card, created_at, updated_at) VALUES ('EG-R-0020', 'seeded', '1.0', '{"version": "1.0", "risk_name": "Regulatory Reporting Drift", "stable_id": "EG-R-0020", "categories": ["governance.compliance"], "merge_hash": "8d86ad260e83c87916790cae9a4e398c79c1b5db711ffc733c4c4690bdb3e735", "provenance": [{"action": "merged", "sources": ["MIT_AIRISK:transparency"]}, {"aiid": "INC-0973", "date": "2024-03-12", "editor": "HAL"}, {"action": "create", "editor": "ICCS", "timestamp": "2025-11-24T16:54:39.059009"}], "description": "Generative AI drafting compliance reports introduces hallucinated citations causing enforcement risk.", "impact_level": 3, "risk_summary": "Generative AI drafting compliance reports introduces hallucinated citations causing enforcement risk.", "ai_model_type": ["generative_ai", "nlp"], "related_risks": ["EG-R-0019"], "energy_context": ["legal_affairs"], "lifecycle_stage": "monitoring", "source_reference": ["AIID:INC-0973", "MIT_AIRISK:transparency"], "impact_dimensions": ["compliance", "reputation"], "known_mitigations": ["Fact-check pipelines", "structured templates"], "probability_level": 3, "trigger_conditions": "Rushed adoption of text generation without guardrails", "operational_priority": 3, "regulatory_requirements": ["EU-AI-Act-TitleIX", "SEC-17A-4"], "technological_dependencies": ["document stores", "LLM services"]}', '2025-11-24 16:54:38.913705', '2025-11-24 16:54:38.913705');
INSERT INTO public.risk (risk_id, status, version, card, created_at, updated_at) VALUES ('EG-R-0021', 'seeded', '1.0', '{"version": "1.0", "risk_name": "Legal Exposure from Data Rights", "stable_id": "EG-R-0021", "categories": ["governance.legal"], "merge_hash": "540a82d3e9c9907b166a2098fdf12614e9e684f7cbe61ac1dd9981c82b39faac", "provenance": [{"action": "merged", "sources": ["MIT_AIRISK:data-rights"]}, {"aiid": "INC-0111", "date": "2024-03-12", "editor": "HAL"}, {"action": "create", "editor": "ICCS", "timestamp": "2025-11-24T16:54:39.065679"}], "description": "Unclear licensing for training data triggers contractual disputes and injunctions on AI services.", "impact_level": 3, "risk_summary": "Unclear licensing for training data triggers contractual disputes and injunctions on AI services.", "ai_model_type": ["generative_ai", "machine_learning"], "related_risks": ["EG-R-0019"], "energy_context": ["legal_affairs"], "lifecycle_stage": "governance", "source_reference": ["AIID:INC-0111", "MIT_AIRISK:data-rights"], "impact_dimensions": ["compliance", "financial"], "known_mitigations": ["data provenance tracking", "License review"], "probability_level": 2, "trigger_conditions": "Use of third-party corpora without audit", "operational_priority": 3, "regulatory_requirements": ["EU-AI-Act-Art52", "US-COPYRIGHT-LAW"], "technological_dependencies": ["content repositories", "Data pipelines"]}', '2025-11-24 16:54:38.913705', '2025-11-24 16:54:38.913705');
INSERT INTO public.risk (risk_id, status, version, card, created_at, updated_at) VALUES ('EG-R-0022', 'seeded', '1.0', '{"version": "1.0", "risk_name": "AI-enabled Privacy Breach Incident", "stable_id": "EG-R-0022", "categories": ["privacy.governance"], "merge_hash": "68f4196818b2c4da2228c4050f3dadec08acb1664ec5cecf944cfc5fd1b6bb26", "provenance": [{"action": "merged", "sources": ["AIID:INC-0444"]}, {"date": "2024-03-13", "editor": "HAL", "mit_airisk": "privacy-incidents"}, {"action": "create", "editor": "ICCS", "timestamp": "2025-11-24T16:54:39.072412"}], "description": "Incident where facial recognition misidentifies workers and leaks attendance data.", "impact_level": 4, "risk_summary": "Incident where facial recognition misidentifies workers and leaks attendance data.", "ai_model_type": ["classification", "computer_vision"], "related_risks": ["EG-R-0004"], "energy_context": ["substation_security"], "lifecycle_stage": "governance", "source_reference": ["AIID:INC-0444", "MIT_AIRISK:privacy-incidents"], "impact_dimensions": ["privacy", "safety"], "known_mitigations": ["improved lighting", "Privacy impact assessments"], "probability_level": 3, "trigger_conditions": "Deployment in poorly lit substations without calibration", "operational_priority": 4, "regulatory_requirements": ["EU-GDPR", "US-BIOMETRIC-PRIVACY-ACTS"], "technological_dependencies": ["Edge cameras", "ID management systems"]}', '2025-11-24 16:54:38.913705', '2025-11-24 16:54:38.913705');
INSERT INTO public.risk (risk_id, status, version, card, created_at, updated_at) VALUES ('EG-R-0023', 'seeded', '1.0', '{"version": "1.0", "risk_name": "Safety Misclassification Incident", "stable_id": "EG-R-0023", "categories": ["safety.incidents"], "merge_hash": "1d74c29a7c0fd83b3778926a567ee3b99818e9b987929e1117374969e205adce", "provenance": [{"action": "merged", "sources": ["AIID:INC-0578"]}, {"date": "2024-03-13", "editor": "ICCS", "mit_airisk": "safety-monitoring"}, {"action": "create", "editor": "ICCS", "timestamp": "2025-11-24T16:54:39.078496"}], "description": "Autonomous drone inspection mislabels structural damage leading to delayed repairs and safety hazard.", "impact_level": 4, "risk_summary": "Autonomous drone inspection mislabels structural damage leading to delayed repairs and safety hazard.", "ai_model_type": ["computer_vision", "reinforcement_learning"], "related_risks": ["EG-R-0013"], "energy_context": ["asset_management"], "lifecycle_stage": "governance", "source_reference": ["AIID:INC-0578", "MIT_AIRISK:safety-monitoring"], "impact_dimensions": ["operational", "safety"], "known_mitigations": ["Domain testing", "human confirmation"], "probability_level": 3, "trigger_conditions": "Model deployed without domain-specific validation", "operational_priority": 4, "regulatory_requirements": ["FAA-PART107", "OSHA-29CFR-1910"], "technological_dependencies": ["Drone platforms", "inspection analytics"]}', '2025-11-24 16:54:38.913705', '2025-11-24 16:54:38.913705');
INSERT INTO public.risk (risk_id, status, version, card, created_at, updated_at) VALUES ('EG-R-0024', 'seeded', '1.0', '{"version": "1.0", "risk_name": "Grid Forecast Outage Incident", "stable_id": "EG-R-0024", "categories": ["governance.monitoring"], "merge_hash": "cae9e9cacbb4c6394a7873595d34a7e2bef287c5b25a08ef9ff4bd17945559e0", "provenance": [{"action": "merged", "sources": ["AIID:INC-0639"]}, {"date": "2024-03-14", "editor": "FORA", "mit_airisk": "monitoring-drift"}, {"action": "create", "editor": "ICCS", "timestamp": "2025-11-24T16:54:39.085268"}], "description": "Forecasting failure during cold snap causes rolling blackouts and financial losses.", "impact_level": 5, "risk_summary": "Forecasting failure during cold snap causes rolling blackouts and financial losses.", "ai_model_type": ["forecasting", "timeseries"], "related_risks": ["EG-R-0010"], "energy_context": ["transmission_planning"], "lifecycle_stage": "governance", "source_reference": ["AIID:INC-0639", "MIT_AIRISK:monitoring-drift"], "impact_dimensions": ["financial", "reliability"], "known_mitigations": ["redundant feeds", "Stress testing"], "probability_level": 4, "trigger_conditions": "Unmodeled extreme weather combined with data latency", "operational_priority": 5, "regulatory_requirements": ["EU-AI-Act-Art9", "NERC-EOP-011"], "technological_dependencies": ["Forecasting clusters", "weather feeds"]}', '2025-11-24 16:54:38.913705', '2025-11-24 16:54:38.913705');


--
-- Data for Name: risk_category; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.risk_category (risk_id, category_id, assignment_type) VALUES ('EG-R-0001', 'technical.attack', 'canonical');
INSERT INTO public.risk_category (risk_id, category_id, assignment_type) VALUES ('EG-R-0002', 'technical.attack', 'canonical');
INSERT INTO public.risk_category (risk_id, category_id, assignment_type) VALUES ('EG-R-0003', 'technical.attack', 'canonical');
INSERT INTO public.risk_category (risk_id, category_id, assignment_type) VALUES ('EG-R-0004', 'privacy.governance', 'canonical');
INSERT INTO public.risk_category (risk_id, category_id, assignment_type) VALUES ('EG-R-0005', 'privacy.governance', 'canonical');
INSERT INTO public.risk_category (risk_id, category_id, assignment_type) VALUES ('EG-R-0006', 'governance.legal', 'canonical');
INSERT INTO public.risk_category (risk_id, category_id, assignment_type) VALUES ('EG-R-0007', 'governance.oversight', 'canonical');
INSERT INTO public.risk_category (risk_id, category_id, assignment_type) VALUES ('EG-R-0008', 'governance.oversight', 'canonical');
INSERT INTO public.risk_category (risk_id, category_id, assignment_type) VALUES ('EG-R-0009', 'governance.oversight', 'canonical');
INSERT INTO public.risk_category (risk_id, category_id, assignment_type) VALUES ('EG-R-0010', 'governance.monitoring', 'canonical');
INSERT INTO public.risk_category (risk_id, category_id, assignment_type) VALUES ('EG-R-0011', 'governance.fairness', 'canonical');
INSERT INTO public.risk_category (risk_id, category_id, assignment_type) VALUES ('EG-R-0012', 'governance.transparency', 'canonical');
INSERT INTO public.risk_category (risk_id, category_id, assignment_type) VALUES ('EG-R-0013', 'governance.oversight', 'canonical');
INSERT INTO public.risk_category (risk_id, category_id, assignment_type) VALUES ('EG-R-0014', 'technical.attack', 'canonical');
INSERT INTO public.risk_category (risk_id, category_id, assignment_type) VALUES ('EG-R-0015', 'technical.attack', 'canonical');
INSERT INTO public.risk_category (risk_id, category_id, assignment_type) VALUES ('EG-R-0016', 'technical.attack', 'canonical');
INSERT INTO public.risk_category (risk_id, category_id, assignment_type) VALUES ('EG-R-0017', 'technical.attack', 'canonical');
INSERT INTO public.risk_category (risk_id, category_id, assignment_type) VALUES ('EG-R-0018', 'governance.monitoring', 'canonical');
INSERT INTO public.risk_category (risk_id, category_id, assignment_type) VALUES ('EG-R-0019', 'governance.compliance', 'canonical');
INSERT INTO public.risk_category (risk_id, category_id, assignment_type) VALUES ('EG-R-0020', 'governance.compliance', 'canonical');
INSERT INTO public.risk_category (risk_id, category_id, assignment_type) VALUES ('EG-R-0021', 'governance.legal', 'canonical');
INSERT INTO public.risk_category (risk_id, category_id, assignment_type) VALUES ('EG-R-0022', 'privacy.governance', 'canonical');
INSERT INTO public.risk_category (risk_id, category_id, assignment_type) VALUES ('EG-R-0023', 'safety.incidents', 'canonical');
INSERT INTO public.risk_category (risk_id, category_id, assignment_type) VALUES ('EG-R-0024', 'governance.monitoring', 'canonical');


--
-- Data for Name: risk_context; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.risk_context (risk_id, context_id, exposure_level) VALUES ('EG-R-0001', 'transmission_control', 3);
INSERT INTO public.risk_context (risk_id, context_id, exposure_level) VALUES ('EG-R-0002', 'transmission_control', 3);
INSERT INTO public.risk_context (risk_id, context_id, exposure_level) VALUES ('EG-R-0003', 'distribution_operations', 3);
INSERT INTO public.risk_context (risk_id, context_id, exposure_level) VALUES ('EG-R-0004', 'retail_energy', 3);
INSERT INTO public.risk_context (risk_id, context_id, exposure_level) VALUES ('EG-R-0005', 'distributed_generation', 3);
INSERT INTO public.risk_context (risk_id, context_id, exposure_level) VALUES ('EG-R-0006', 'market_operations', 3);
INSERT INTO public.risk_context (risk_id, context_id, exposure_level) VALUES ('EG-R-0007', 'control_rooms', 3);
INSERT INTO public.risk_context (risk_id, context_id, exposure_level) VALUES ('EG-R-0008', 'control_rooms', 3);
INSERT INTO public.risk_context (risk_id, context_id, exposure_level) VALUES ('EG-R-0009', 'market_operations', 3);
INSERT INTO public.risk_context (risk_id, context_id, exposure_level) VALUES ('EG-R-0010', 'transmission_planning', 3);
INSERT INTO public.risk_context (risk_id, context_id, exposure_level) VALUES ('EG-R-0011', 'distribution_operations', 3);
INSERT INTO public.risk_context (risk_id, context_id, exposure_level) VALUES ('EG-R-0012', 'public_affairs', 3);
INSERT INTO public.risk_context (risk_id, context_id, exposure_level) VALUES ('EG-R-0013', 'distribution_operations', 3);
INSERT INTO public.risk_context (risk_id, context_id, exposure_level) VALUES ('EG-R-0014', 'transmission_control', 3);
INSERT INTO public.risk_context (risk_id, context_id, exposure_level) VALUES ('EG-R-0015', 'supply_chain', 3);
INSERT INTO public.risk_context (risk_id, context_id, exposure_level) VALUES ('EG-R-0016', 'enterprise_it', 3);
INSERT INTO public.risk_context (risk_id, context_id, exposure_level) VALUES ('EG-R-0017', 'transmission_control', 3);
INSERT INTO public.risk_context (risk_id, context_id, exposure_level) VALUES ('EG-R-0018', 'retail_energy', 3);
INSERT INTO public.risk_context (risk_id, context_id, exposure_level) VALUES ('EG-R-0019', 'legal_affairs', 3);
INSERT INTO public.risk_context (risk_id, context_id, exposure_level) VALUES ('EG-R-0020', 'legal_affairs', 3);
INSERT INTO public.risk_context (risk_id, context_id, exposure_level) VALUES ('EG-R-0021', 'legal_affairs', 3);
INSERT INTO public.risk_context (risk_id, context_id, exposure_level) VALUES ('EG-R-0022', 'substation_security', 3);
INSERT INTO public.risk_context (risk_id, context_id, exposure_level) VALUES ('EG-R-0023', 'asset_management', 3);
INSERT INTO public.risk_context (risk_id, context_id, exposure_level) VALUES ('EG-R-0024', 'transmission_planning', 3);


--
-- Name: category category_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.category
    ADD CONSTRAINT category_pkey PRIMARY KEY (category_id);


--
-- Name: energy_context energy_context_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.energy_context
    ADD CONSTRAINT energy_context_name_key UNIQUE (name);


--
-- Name: energy_context energy_context_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.energy_context
    ADD CONSTRAINT energy_context_pkey PRIMARY KEY (context_id);


--
-- Name: risk_category risk_category_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.risk_category
    ADD CONSTRAINT risk_category_pkey PRIMARY KEY (risk_id, category_id);


--
-- Name: risk_context risk_context_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.risk_context
    ADD CONSTRAINT risk_context_pkey PRIMARY KEY (risk_id, context_id);


--
-- Name: risk risk_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.risk
    ADD CONSTRAINT risk_pkey PRIMARY KEY (risk_id);


--
-- Name: risk_card_gin_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX risk_card_gin_idx ON public.risk USING gin (card jsonb_path_ops);


--
-- Name: risk_category_category_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX risk_category_category_id_idx ON public.risk_category USING btree (category_id);


--
-- Name: risk_category_risk_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX risk_category_risk_id_idx ON public.risk_category USING btree (risk_id);


--
-- Name: risk_context_context_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX risk_context_context_id_idx ON public.risk_context USING btree (context_id);


--
-- Name: risk_context_risk_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX risk_context_risk_id_idx ON public.risk_context USING btree (risk_id);


--
-- Name: risk trg_set_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_set_updated_at BEFORE UPDATE ON public.risk FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- Name: category category_parent_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.category
    ADD CONSTRAINT category_parent_category_id_fkey FOREIGN KEY (parent_category_id) REFERENCES public.category(category_id);


--
-- Name: risk_category risk_category_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.risk_category
    ADD CONSTRAINT risk_category_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.category(category_id) ON DELETE CASCADE;


--
-- Name: risk_category risk_category_risk_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.risk_category
    ADD CONSTRAINT risk_category_risk_id_fkey FOREIGN KEY (risk_id) REFERENCES public.risk(risk_id) ON DELETE CASCADE;


--
-- Name: risk_context risk_context_context_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.risk_context
    ADD CONSTRAINT risk_context_context_id_fkey FOREIGN KEY (context_id) REFERENCES public.energy_context(context_id) ON DELETE CASCADE;


--
-- Name: risk_context risk_context_risk_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.risk_context
    ADD CONSTRAINT risk_context_risk_id_fkey FOREIGN KEY (risk_id) REFERENCES public.risk(risk_id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--


