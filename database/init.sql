BEGIN;

CREATE TABLE IF NOT EXISTS usuarios (
    id BIGSERIAL PRIMARY KEY,
    nome VARCHAR(150) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    senha_hash VARCHAR(255) NOT NULL,
    perfil VARCHAR(20) NOT NULL DEFAULT 'usuario'
        CHECK (perfil IN ('usuario', 'administrador')),
    ativo BOOLEAN NOT NULL DEFAULT TRUE,
    criado_em TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);


CREATE TABLE IF NOT EXISTS livros (
    id BIGSERIAL PRIMARY KEY,
    titulo VARCHAR(255) NOT NULL,
    autor VARCHAR(255) NOT NULL,
    isbn VARCHAR(20) UNIQUE,
    disponivel BOOLEAN NOT NULL DEFAULT TRUE,
    criado_em TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);


CREATE TABLE IF NOT EXISTS emprestimos (
    id BIGSERIAL PRIMARY KEY,
    usuario_id BIGINT NOT NULL,
    livro_id BIGINT NOT NULL,
    data_emprestimo TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    data_prevista_devolucao TIMESTAMP WITH TIME ZONE,
    data_devolucao TIMESTAMP WITH TIME ZONE,
    status VARCHAR(20) NOT NULL DEFAULT 'ativo'
        CHECK (status IN ('ativo', 'devolvido', 'atrasado', 'cancelado')),

    CONSTRAINT fk_emprestimos_usuario
        FOREIGN KEY (usuario_id) REFERENCES usuarios(id)
        ON UPDATE CASCADE ON DELETE RESTRICT,

    CONSTRAINT fk_emprestimos_livro
        FOREIGN KEY (livro_id) REFERENCES livros(id)
        ON UPDATE CASCADE ON DELETE RESTRICT,

    CONSTRAINT chk_data_devolucao
        CHECK (data_devolucao IS NULL OR data_devolucao >= data_emprestimo)
);


CREATE UNIQUE INDEX IF NOT EXISTS uq_emprestimo_livro_ativo
    ON emprestimos (livro_id)
    WHERE status = 'ativo';

CREATE INDEX IF NOT EXISTS idx_emprestimos_usuario
    ON emprestimos (usuario_id);

CREATE INDEX IF NOT EXISTS idx_emprestimos_livro
    ON emprestimos (livro_id);

CREATE INDEX IF NOT EXISTS idx_emprestimos_status
    ON emprestimos (status);


CREATE TABLE IF NOT EXISTS notificacoes (
    id BIGSERIAL PRIMARY KEY,
    usuario_id BIGINT,
    emprestimo_id BIGINT,
    tipo VARCHAR(30) NOT NULL,
    mensagem TEXT NOT NULL,
    enviada BOOLEAN NOT NULL DEFAULT FALSE,
    criada_em TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_notificacoes_usuario
        FOREIGN KEY (usuario_id) REFERENCES usuarios(id)
        ON UPDATE CASCADE ON DELETE SET NULL,

    CONSTRAINT fk_notificacoes_emprestimo
        FOREIGN KEY (emprestimo_id) REFERENCES emprestimos(id)
        ON UPDATE CASCADE ON DELETE SET NULL
);


CREATE TABLE IF NOT EXISTS logs_operacoes (
    id BIGSERIAL PRIMARY KEY,
    usuario_id BIGINT,
    servico VARCHAR(60) NOT NULL,
    operacao VARCHAR(100) NOT NULL,
    recurso VARCHAR(100),
    recurso_id BIGINT,
    detalhes TEXT,
    sucesso BOOLEAN NOT NULL DEFAULT TRUE,
    criado_em TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_logs_usuario
        FOREIGN KEY (usuario_id) REFERENCES usuarios(id)
        ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE INDEX IF NOT EXISTS idx_logs_servico
    ON logs_operacoes (servico);

CREATE INDEX IF NOT EXISTS idx_logs_criado_em
    ON logs_operacoes (criado_em);

COMMIT;
