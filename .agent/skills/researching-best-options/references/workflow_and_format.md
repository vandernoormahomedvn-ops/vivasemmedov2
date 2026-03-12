# Workflow for Researching Best Options

## Workflow Steps

1.  **Analisar o Pedido**: Identificar claramente o objeto da pesquisa (ex: "fones de ouvido cancelamento de ruído", "frameworks web", "restaurantes italianos em Lisboa").
2.  **Pesquisa na Web (Search)**:
    - Realizar buscas focadas em reviews recentes e comparativos.
    - Termos sugeridos: "melhores [tópico] [ano atual]", "top rated [topic] reviews", "[topic] comparison".
    - Para temas técnicos do ecossistema Google, utilize prioritariamente o **`mcp_google-developer-knowledge_search_documents`**.
    - Para Flutter/Dart, use `mcp_dart-mcp-server_pub_dev_search` para encontrar os melhores pacotes.
3.  **Leitura e Extração (Scrape)**:
    - Ler 2 a 3 fontes de alta autoridade (tech blogs, reviews especializados, discussões no Reddit).
    - Identificar os produtos que aparecem consistentemente no topo.
4.  **Seleção das 3 Melhores**:
    - Escolher 3 opções distintas para cobrir diferentes necessidades:
        - **Opção 1:** A Melhor Geral (Overall Best)
        - **Opção 2:** Melhor Custo-Benefício (Best Value)
        - **Opção 3:** Melhor Alternativa / Premium / Específica
5.  **Apresentação**:
    - Apresentar o resultado final de forma clara e estruturada.

## Output Format

Para cada uma das 3 opções, forneça:

### 1. [Nome da Opção]
- **Categoria**: (Melhor Geral / Custo-Benefício / etc)
- **Por que ganhou**: Uma frase resumindo o motivo da escolha.
- **Prós**:
    - Pro 1
    - Pro 2
- **Contras**:
    - Contra 1
- **Preço Estimado**: (Se disponível)

---
(Repetir para as outras 2 opções)

## Exemplo de Prompt Interno

Se o usuário perguntar "Melhores mouses", você deve executar:
`search_web(query="best ergonomic mouse 2025 reviews")`
`read_url_content(...)`
E então compilar a resposta seguindo o formato acima.
