# TaskFlow

TaskFlow é um aplicativo de lista de tarefas desenvolvido com Flutter e Dart.
Ele permite que cada usuário crie uma conta, organize suas tarefas e acompanhe
o que já foi concluído. A autenticação e a persistência dos dados são fornecidas
pelo Supabase.

## Descrição do Aplicativo

O aplicativo oferece uma interface simples para manter tarefas pessoais
sincronizadas com uma base de dados na nuvem. As tarefas são associadas à conta
autenticada, e as políticas de segurança do Supabase restringem o acesso aos
registros do próprio usuário.

## Funcionalidades Principais

- Cadastro de conta e login com e-mail e senha.
- Criação de tarefas com título e descrição opcional.
- Edição de título e descrição.
- Marcação de tarefas como concluídas ou pendentes.
- Exclusão de tarefas.
- Carregamento das tarefas do usuário autenticado, ordenadas das mais recentes
  para as mais antigas.
- Proteção dos dados por Row Level Security (RLS).

## Tecnologias Utilizadas

- **Flutter**: framework para a interface multiplataforma.
- **Dart**: linguagem de programação do aplicativo.
- **Supabase**: autenticação e banco de dados PostgreSQL.

## Arquitetura do Projeto

```text
lib/
├── main.dart
├── models/
│   └── task_model.dart
├── screens/
│   ├── home_screen.dart
│   ├── login_screen.dart
│   └── register_screen.dart
├── services/
│   ├── auth_service.dart
│   └── database_service.dart
└── widgets/
    └── task_tile.dart
```

- `models/`: representa os dados de tarefa e a conversão para/de mapas.
- `services/`: concentra operações de autenticação e acesso ao Supabase.
- `screens/`: contém as telas de login, cadastro e gerenciamento de tarefas.
- `widgets/`: contém componentes reutilizáveis da interface.

## Autenticação e Base de Dados

O `AuthService` usa o Supabase Auth para cadastrar, autenticar e encerrar a
sessão do usuário. O `DatabaseService` realiza operações na tabela `tasks`.
Cada tarefa possui um `user_id` vinculado ao identificador do usuário do
Supabase Auth. Com RLS habilitado, as políticas abaixo autorizam cada usuário
autenticado a acessar somente suas próprias tarefas.

Execute este script no SQL Editor do projeto Supabase:

```sql
create table public.tasks (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  title text not null,
  description text not null default '',
  is_done boolean not null default false,
  created_at timestamptz not null default now()
);

alter table public.tasks enable row level security;

create policy "Users can read their own tasks"
on public.tasks
for select
to authenticated
using (auth.uid() = user_id);

create policy "Users can create their own tasks"
on public.tasks
for insert
to authenticated
with check (auth.uid() = user_id);

create policy "Users can update their own tasks"
on public.tasks
for update
to authenticated
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

create policy "Users can delete their own tasks"
on public.tasks
for delete
to authenticated
using (auth.uid() = user_id);
```

## Instruções para Executar o Projeto

1. Instale o Flutter e configure um dispositivo ou emulador compatível.
2. Crie um projeto no Supabase e execute o script SQL acima.
3. Configure as credenciais do projeto em `lib/main.dart`, substituindo
   `SUA_SUPABASE_URL_AQUI` pela URL do projeto e
   `SUA_SUPABASE_ANON_KEY_AQUI` pela chave pública anon.
4. Garanta que o pacote `supabase_flutter` esteja listado nas dependências do
   projeto.
5. Na raiz do projeto, instale as dependências e execute o aplicativo:

   ```sh
   flutter pub get
   flutter run
   ```