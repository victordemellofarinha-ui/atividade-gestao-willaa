create table colaboradores(
id serial primary key,
nome varchar(150) not null,
email varchar(150) unique not null,
senha varchar(200) unique not null,
ativo boolean default true not null
);

create table projetos(
id serial primary key,
nome varchar(200) not null,
descricao text not null,
status varchar(150) default 'Andamento' check(status in('Andamento', 'Cancelado', 'Parado'))
);

create table tarefas(
id serial primary key,
id_projeto int REFERENCES projetos(id) not null,
id_colaborador int references colaboradores(id) not null,
titulo varchar(150) not null,
categoria varchar(250) not null,
descricao text not null,
data_agendamento timestamp default current_timestamp not null,
prazo_entrega date not null,
status varchar(150) default 'Andamento' check(status in('Andamento', 'Cancelado', 'Parado'))
);

create table historico_tarefas(
id serial primary key,
id_tarefa int references tarefas(id) not null,
evento varchar(150) not null,
data_evento timestamp default CURRENT_TIMESTAMP not null,
detalhes text
);

create view vw_painel_principal as
select
colaboradores.nome,
tarefas.titulo,
tarefas.categoria,
tarefas.prazo_entrega as prazo,
tarefas.status
from tarefas
join colaboradores
on tarefas.id_colaborador = colaboradores.id



CREATE VIEW vw_cronograma_prazos AS
SELECT
colaboradores.nome,
tarefas.titulo,
tarefas.categoria,
tarefas.data_agendamento,
tarefas.prazo_entrega,
tarefas.status
FROM tarefas
JOIN colaboradores
ON tarefas.id_colaborador = colaboradores.id
ORDER BY tarefas.prazo_entrega ASC;



CREATE OR REPLACE FUNCTION fn_validar_tarefa()
RETURNS TRIGGER AS $$
BEGIN

IF NOT EXISTS (
SELECT id
FROM colaboradores
WHERE id = NEW.id_colaborador
AND ativo = TRUE)
THEN
RAISE EXCEPTION 'Colaborador inativo ou inexistente';
END IF;
NEW.data_criacao = CURRENT_TIMESTAMP;
INSERT INTO historico_tarefas (id_tarefa, evento, detalhes)
VALUES (NEW.id, 'CRIACAO', 'Tarefa cadastrada no sistema');
RETURN NEW;
END;
$$ LANGUAGE plpgsql;






