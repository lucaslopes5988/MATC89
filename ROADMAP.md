---

## Registro de Iterações

### Iteração 1 — Mapa e Autoidentificação (02/07/2026)

#### O que foi feito

**Mapa integrado com Google Maps**

- Adicionada a dependência do `google_maps_flutter` ao projeto.
- Implementado o widget `EventLocationMap`, que exibe um mapa estático (lite mode no Android) na tela de detalhes do evento com um marcador na localização do evento.
- O mapa na tela de detalhes tem o botão "Abrir no mapa" que abre o app de mapas nativo do dispositivo (Google Maps no Android, Apple Maps no iOS) com as coordenadas do evento.
- Implementado o widget `LocationPickerField` para a tela de criação de evento. O usuário pode selecionar a localização do evento tocando no mapa ou arrastando o marcador. Também há um botão "Usar minha localização" que solicita permissão de localização e centraliza o mapa na posição atual.
- Adicionada pesquisa de localização por texto na criação de evento usando o pacote `geocoding`. O campo de texto permite digitar um endereço e buscar as coordenadas. Quando há múltiplos resultados, um bottom sheet é exibido para o usuário escolher o local correto.
- Adicionado o `LocationPermissionHandler` para gerenciar permissões de localização de forma centralizada.

**Autoidentificação de gênero**

- Criado o modelo `GenderIdentity` com os valores: `woman`, `man`, `nonBinary` e `preferNotToSay`.
- Implementada a seção de identidade de gênero na tela de perfil (`ProfilePage`) usando `ChoiceChip` para seleção. O usuário pode selecionar ou desselecionar sua identidade de gênero.
- O perfil é salvo no Firestore através do `ProfileRepository` e `ProfileCubit`.
- A informação de gênero é usada para controlar o acesso a eventos exclusivos para mulheres:
  - O `MainShellPage` carrega o perfil do usuário e verifica se `profile.isWoman` é verdadeiro.
  - O flag `isWoman` é propagado para `ExplorePage`, `EventDetailsPage` e `EventDetailsCubit`.
  - No `EventDetailsCubit`, ao carregar um evento marcado como `womenOnly`, se `isWoman` for `false`, o evento exibe um erro informando que é exclusivo para mulheres.

**Criação de eventos com flag "Somente mulheres"**

- Adicionado o campo `womenOnly` ao modelo `Event` e ao DTO `EventDbDto`.
- Na tela de criação de evento, foi adicionado um `SwitchListTile` para marcar o evento como exclusivo para mulheres.
- O badge "Somente mulheres" é exibido nos cards de evento e na tela de detalhes quando o evento possui esse flag.

**Tela de detalhes do evento**

- Exibe título, descrição, categoria (chip), badge de "Somente mulheres", data/hora, local, organizador, contagem de participantes e mapa com localização.
- Botões de "Confirmar presença" e "Cancelar presença" com estados de loading.
- Mensagens de status: "Você é o organizador", "Você já confirmou presença", "Evento lotado".
- O organizador não pode sair do próprio evento.

**Estrutura do projeto**

- Arquitetura modular com feature packages separados: `auth`, `events`, `profile`, `core`, `design_system`, `commons`.
- Uso de BLoC/Cubit para gerenciamento de estado.
- Injeção de dependência com `get_it` e `injectable`.
- Backend com Firebase (Firestore para dados, Firebase Auth para autenticação).
- Design system próprio (`PlayceColors`, `PlayceSpacing`, `PlayceRadius`, componentes `Playce*`).

#### Pontos de atenção

1. **Bug na pesquisa de localização ao criar evento**: A busca por localização via texto está funcionando (o mapa mostra o local correto quando encontrado), porém exibe a mensagem de erro "O local não foi encontrado" mesmo quando o local é adicionado com sucesso. O fluxo ideal seria ir mostrando uma lista de locais encontrados conforme o usuário digita (autocomplete), em vez de buscar somente ao clicar no botão de pesquisa. Atualmente, se houver apenas 1 resultado, ele é aplicado diretamente sem mostrar opções; se houver múltiplos, abre um bottom sheet. A mensagem de erro falsa provavelmente vem do bloco `catch` genérico no método `_searchLocation()` que trata qualquer exceção como "local não encontrado".

2. **Tela de perfil muito básica**: A `ProfilePage` atual mostra apenas o avatar, nome, email e a seção de seleção de identidade de gênero com chips, além do botão de logout. Não há campos para editar nome, bio, cidade, esportes de interesse ou nível de prática. O ideal seria ter um fluxo separado e mais elaborado para a seleção de gênero (possivelmente uma tela dedicada ou um modal com mais contexto e explicação), e expandir o perfil com as demais informações previstas no roadmap (seção 3.1).

3. **Falta busca por eventos no Mapa**: A aba "Mapa" na navegação principal (`MainShellPage`) ainda é um placeholder (`_PlaceholderTab`) sem funcionalidade real. É super importante implementar a exibição de eventos como marcadores no mapa interativo antes da entrega final. Essa é a funcionalidade principal do app (seção 4 do roadmap) e o diferencial do produto. O mapa deve mostrar eventos próximos, permitir tocar em marcadores para ver detalhes e idealmente filtrar por categoria.

4. **Verificar restrição de eventos "Somente mulheres"**: A lógica de restrição de eventos `womenOnly` precisa ser verificada de ponta a ponta. Atualmente, o `EventDetailsCubit` bloqueia o acesso a detalhes de eventos `womenOnly` se `isWoman` for `false`, mas é necessário confirmar que:
   - O botão de "Confirmar presença" também está de fato desabilitado/bloqueado para usuários que não são mulheres (e não apenas a visualização dos detalhes).
   - Na listagem (`ExplorePage`), eventos `womenOnly` continuam visíveis para todos (apenas a confirmação deve ser restrita), ou se devem ser filtrados da lista para não-mulheres.
   - A flag `isWoman` está sendo corretamente derivada do perfil salvo no Firestore (e não apenas do estado local).
   - Qualquer usuário que cria um evento "Somente mulheres" pode fazê-lo independente do gênero, ou se essa opção deveria ser restrita.

---

O app deve funcionar como uma rede social geolocalizada para encontros esportivos e eventos presenciais.

O usuário abre o mapa, vê eventos próximos, toca em um marcador, entende o que vai acontecer, quem está participando e decide se quer confirmar presença.

Exemplo principal:

“Vou correr hoje às 18h na praça. Crio um evento de corrida, marco o local no mapa e confirmo minha presença. Outras pessoas veem esse evento e podem participar.”

O app deve servir tanto para encontros pequenos, como uma pessoa procurando companhia para correr, quanto para grupos maiores, como partidas de futebol, treinos coletivos, aulas abertas, eventos de bike ou encontros esportivos organizados.

2. Tipos principais de eventos

O app pode começar com uma estrutura simples, mas flexível.

Os eventos podem ser divididos em:

Evento individual: criado por uma pessoa que quer companhia. Exemplo: “Corrida leve hoje às 18h”.

Evento em grupo: criado por um grupo, assessoria, time ou comunidade. Exemplo: “Treino funcional do grupo X”.

Evento público: qualquer pessoa pode visualizar e confirmar presença.

Evento privado ou restrito: somente convidados, membros de um grupo ou pessoas com link conseguem acessar.

Evento recorrente: acontece toda semana ou em dias definidos. Exemplo: “Corrida toda terça e quinta às 6h”.

Evento único: acontece apenas uma vez.

No início, eu recomendo priorizar eventos públicos e únicos, porque isso deixa o produto mais simples e rápido de validar.

3. Funcionalidades principais
3.1 Cadastro e perfil do usuário

O usuário precisa ter uma identidade mínima para criar eventos e confirmar presença.

Funcionalidades:

Criar conta.

Entrar na conta.

Editar perfil.

Adicionar foto.

Adicionar nome ou apelido.

Adicionar cidade ou região.

Adicionar esportes de interesse.

Adicionar nível de prática, por exemplo: iniciante, intermediário ou avançado.

Adicionar descrição curta.

Adicionar informação de gênero do usuário caso seja mulher (para acessar eventos exclusivos.)

Visualizar perfil de outros usuários.

Ver eventos que o usuário criou.

Ver eventos em que o usuário confirmou presença.

Essa parte é importante porque, antes de encontrar alguém presencialmente, as pessoas querem ter algum nível de confiança sobre quem vai estar lá.

4. Mapa de eventos

Essa é a funcionalidade principal do app.

O usuário deve conseguir abrir o mapa e visualizar eventos próximos.

Funcionalidades:

Exibir eventos como marcadores no mapa.

Mostrar marcadores diferentes por tipo de esporte ou categoria.

Permitir tocar em um marcador para abrir um resumo do evento.

Permitir aproximar e afastar o mapa.

Atualizar eventos conforme o usuário muda a região do mapa.

Mostrar eventos próximos à localização atual do usuário.

Permitir buscar eventos em outra cidade ou região.

Agrupar marcadores quando houver muitos eventos próximos.

Diferenciar eventos que já começaram, eventos futuros e eventos encerrados.

O mapa precisa responder perguntas simples:

“O que está acontecendo perto de mim?”

“O que vai acontecer hoje?”

“Tem alguém correndo perto de mim mais tarde?”

“Tem algum futebol, treino ou pedal marcado?”

5. Criação de eventos

Criar evento deve ser simples e rápido. Quanto mais campos obrigatórios, maior a chance de o usuário desistir.

Campos essenciais:

Título do evento.

Categoria ou esporte.

Local no mapa.

Data.

Horário de início.

Horário de término ou duração estimada.

Descrição curta.

Quantidade de vagas, opcional.

Nível recomendado, opcional.

Visibilidade: público ou privado, se essa opção existir.

Confirmação automática da presença do criador.

Exemplo de criação:

Título: Corrida leve na praça
Categoria: Corrida
Local: Praça X
Data: Hoje
Horário: 18h
Duração: 1 hora
Descrição: Ritmo leve, cerca de 5 km.

Funcionalidades importantes:

Selecionar local tocando no mapa.

Usar localização atual como ponto do evento.

Editar evento depois de criado.

Cancelar evento.

Duplicar evento, útil para eventos parecidos.

Definir se outras pessoas podem convidar participantes.

Definir limite de participantes, quando necessário.

6. Página de detalhes do evento

Quando o usuário toca em um evento no mapa, ele deve ver informações suficientes para decidir se quer participar.

Informações importantes:

Título.

Esporte ou categoria.

Local.

Data e horário.

Distância aproximada até o usuário.

Descrição.

Criador do evento.

Lista de participantes confirmados.

Quantidade de pessoas confirmadas.

Nível recomendado.

Botão para confirmar presença.

Botão para cancelar presença.

Botão para compartilhar evento.

Botão para abrir rota até o local.

Status do evento: aberto, lotado, cancelado, encerrado ou em andamento.

Também é interessante mostrar avisos simples:

“Este evento começa em 2 horas.”

“Este evento já começou.”

“Este evento foi cancelado.”

“Evento lotado.”

“Você já confirmou presença.”

7. Confirmação de presença

A confirmação de presença é uma das ações mais importantes do app.

Funcionalidades:

Confirmar presença em um evento.

Cancelar presença.

Ver quem confirmou presença.

Mostrar número total de confirmados.

Impedir confirmação caso o evento esteja encerrado, cancelado ou lotado.

Permitir lista de espera, se houver limite de vagas.

Notificar o criador quando alguém confirmar presença.

Notificar os participantes se o evento for alterado ou cancelado.

Fluxo ideal:

O usuário encontra um evento no mapa.

Abre os detalhes.

Lê as informações.

Toca em “Confirmar presença”.

O app mostra uma confirmação clara, como: “Presença confirmada”.

O evento passa a aparecer na agenda do usuário.

8. Agenda do usuário

Além do mapa, o usuário precisa ter uma área para ver os eventos dele.

Funcionalidades:

Ver próximos eventos confirmados.

Ver eventos criados pelo usuário.

Ver histórico de eventos passados.

Cancelar presença em eventos futuros.

Editar eventos criados.

Cancelar eventos criados.

Receber lembretes antes do evento.

A agenda pode ser dividida em:

“Vou participar”

“Criados por mim”

“Histórico”

Essa área ajuda o app a não depender somente do mapa. Depois que o usuário confirma presença, ele precisa conseguir encontrar o evento facilmente.

9. Filtros e busca

Com o tempo, muitos eventos podem aparecer no mapa. Por isso, filtros são essenciais.

Filtros úteis:

Categoria ou esporte.

Data.

Horário.

Distância.

Nível.

Eventos com vagas disponíveis.

Eventos gratuitos ou pagos, se existirem eventos pagos.

Eventos criados por grupos.

Eventos individuais.

Eventos que meus amigos vão participar.

Filtros iniciais recomendados:

Esporte.

Data.

Distância.

Horário.

Com esses quatro filtros, o usuário já consegue encontrar eventos úteis sem complexidade demais.

10. Categorias de esportes e eventos

O app pode começar com categorias populares e depois expandir.

Categorias iniciais:

Corrida.

Caminhada.

Ciclismo.

Futebol.

Vôlei.

Basquete.

Tênis.

Funcional.

Yoga.

Trilha.

Skate.

Outros.

Também pode existir uma categoria genérica chamada “Evento esportivo” ou “Atividade ao ar livre”, para casos que não se encaixam perfeitamente.

11. Grupos e comunidades

Essa funcionalidade pode ser uma segunda fase do app. Ela aumenta muito o potencial do produto, mas também aumenta a complexidade.

Funcionalidades:

Criar grupo.

Entrar em grupo.

Sair de grupo.

Ver membros do grupo.

Criar eventos associados ao grupo.

Ver eventos do grupo.

Definir administradores.

Aprovar entrada de novos membros, se o grupo for fechado.

Enviar aviso para membros do grupo quando um evento for criado.

Exemplo:

Um grupo chamado “Corredores da Barra” cria treinos toda terça e quinta. Os membros recebem notificação e podem confirmar presença.

Essa função transforma o app de um simples mapa de eventos em uma plataforma de comunidades locais.

12. Comunicação entre participantes

O app pode ter algum tipo de comunicação, mas é bom tomar cuidado para não deixar isso complexo demais no início.

Opções possíveis:

Comentários dentro do evento.

Chat do evento.

Mensagens diretas entre usuários.

Avisos oficiais do criador.

Para uma primeira versão, eu recomendo começar com comentários no evento, não chat privado.

Comentários resolvem coisas simples como:

“Vai ser ritmo leve?”

“O ponto de encontro é na entrada principal?”

“Vai acontecer mesmo se chover?”

“Alguém vai de bike até lá?”

Depois, se o app crescer, pode ser adicionada uma conversa em grupo por evento.

13. Notificações

Notificações são fundamentais para manter o usuário engajado.

Notificações importantes:

Alguém confirmou presença no evento que você criou.

O evento que você confirmou foi alterado.

O evento que você confirmou foi cancelado.

Lembrete antes do evento.

Novo evento próximo de você.

Novo evento de um esporte que você segue.

Novo evento criado por um grupo que você participa.

Alguém comentou no evento.

Para evitar incômodo, o usuário deve poder controlar quais notificações quer receber.

14. Regras de negócio

Aqui ficam as regras que controlam o funcionamento do app.

Um evento precisa ter local, data, horário e categoria.

O criador do evento deve ser automaticamente confirmado como participante.

Um usuário não pode confirmar presença duas vezes no mesmo evento.

Um usuário pode cancelar a própria presença antes do evento começar.

Eventos passados devem sair do destaque principal do mapa.

Eventos cancelados não devem permitir novas confirmações.

Eventos lotados não devem permitir novas confirmações, exceto se houver lista de espera.

O criador pode editar informações do evento.

Se data, horário ou local forem alterados, os participantes devem ser notificados.

O criador pode cancelar o evento.

Participantes devem ser avisados quando o evento for cancelado.

Eventos públicos aparecem no mapa.

Eventos privados não aparecem publicamente no mapa.

Eventos muito antigos devem ficar apenas no histórico.

15. Status dos eventos

Todo evento deve ter um status. Isso ajuda o app a decidir o que mostrar e quais ações permitir.

Status sugeridos:

Rascunho: evento ainda não publicado.

Aberto: evento publicado e aceitando participantes.

Lotado: atingiu o limite de participantes.

Em andamento: o horário do evento já começou.

Encerrado: evento já terminou.

Cancelado: evento foi cancelado pelo criador.

Privado: evento acessível apenas para convidados ou grupo.

Na primeira versão, você pode usar apenas: aberto, encerrado e cancelado.

16. Segurança e confiança

Como o app envolve encontros presenciais, segurança é muito importante.

Funcionalidades recomendadas:

Denunciar evento.

Denunciar usuário.

Bloquear usuário.

Ocultar eventos de usuários bloqueados.

Moderação de eventos denunciados.

Remover eventos inadequados.

Impedir spam de criação de eventos.

Limitar quantidade de eventos criados por usuário novo.

Verificar conta, em uma fase futura.

Mostrar orientações básicas de segurança.

Exemplo de aviso:

“Encontre-se em locais públicos, avise alguém de confiança e confira as informações do evento antes de ir.”

Isso não precisa assustar o usuário, mas precisa existir.

17. Privacidade

O app usa localização, então privacidade precisa ser tratada com cuidado.

Funcionalidades e regras:

O usuário deve escolher se permite acesso à localização.

A localização exata do usuário não deve ser mostrada para outras pessoas.

O app mostra o local do evento, não a posição atual dos participantes.

O usuário pode usar o app pesquisando manualmente uma região, sem localização automática.

Eventos privados devem aparecer somente para pessoas autorizadas.

O perfil do usuário deve mostrar apenas informações públicas.

O usuário pode excluir sua conta.

O usuário pode remover foto, bio e informações pessoais.

18. Sistema de reputação

Essa funcionalidade pode entrar depois que o app já tiver usuários.

Possibilidades:

Avaliar evento depois que ele acontece.

Marcar se o evento realmente aconteceu.

Avaliar organização do criador.

Sinalizar ausência do criador.

Mostrar quantidade de eventos que o usuário já criou.

Mostrar quantidade de eventos em que o usuário participou.

Dar selo para usuários ativos e confiáveis.

Cuidado: avaliações entre usuários podem gerar conflitos. Uma alternativa mais segura é avaliar o evento, não diretamente a pessoa.

19. Funcionalidades sociais

Depois da primeira versão, o app pode crescer como rede social local.

Funcionalidades possíveis:

Seguir usuários.

Ver eventos de pessoas que sigo.

Adicionar amigos.

Ver amigos confirmados em eventos.

Compartilhar evento fora do app.

Feed de eventos próximos.

Sugestões personalizadas.

Ranking de grupos mais ativos.

Conquistas por participação.

Essas funções aumentam engajamento, mas não são essenciais para o MVP.

20. MVP — primeira versão recomendada

O MVP deve ser a menor versão útil do app.

Eu recomendo começar com:

Cadastro e login.

Perfil simples.

Mapa com eventos.

Criar evento público.

Selecionar local no mapa.

Confirmar presença.

Cancelar presença.

Ver detalhes do evento.

Ver participantes confirmados.

Ver meus eventos.

Cancelar evento criado.

Filtros básicos por esporte e data.

Notificações simples.

Denunciar evento.

Com isso, o app já consegue provar a ideia principal:

“Consigo criar um evento em um lugar e horário, outras pessoas conseguem ver no mapa e confirmar presença.”

21. Segunda versão

Depois do MVP, entram funções que melhoram uso e retenção.

Sugestões:

Comentários no evento.

Filtros por distância e horário.

Eventos recorrentes.

Compartilhamento de evento.

Abrir rota até o local.

Lista de espera.

Limite de participantes.

Notificações mais completas.

Eventos privados por link.

Histórico de eventos.

Bloquear usuário.

Denunciar usuário.

22. Terceira versão

Aqui entram funcionalidades de comunidade.

Sugestões:

Criação de grupos.

Eventos associados a grupos.

Membros e administradores.

Eventos exclusivos para grupos.

Convites.

Aprovação de membros.

Feed de eventos dos grupos.

Reputação de eventos.

Perfis mais completos.

Sugestões personalizadas.

23. Fluxos principais do usuário
Fluxo 1: criar evento individual

O usuário abre o app.

Toca em criar evento.

Escolhe categoria, por exemplo corrida.

Seleciona local no mapa.

Define data e horário.

Escreve uma descrição curta.

Publica o evento.

O app confirma automaticamente a presença do criador.

O evento aparece no mapa para outros usuários.

Fluxo 2: participar de evento

O usuário abre o mapa.

Vê eventos próximos.

Toca em um marcador.

Lê os detalhes.

Vê quem já confirmou presença.

Toca em confirmar presença.

O evento entra na agenda dele.

O criador recebe uma notificação.

Fluxo 3: cancelar presença

O usuário entra em “Meus eventos”.

Abre o evento.

Toca em cancelar presença.

O app remove o usuário da lista de participantes.

A quantidade de confirmados é atualizada.

Fluxo 4: cancelar evento criado

O criador entra no evento.

Toca em cancelar evento.

Confirma o cancelamento.

O evento muda para status cancelado.

Participantes recebem notificação.

O evento deixa de aceitar novas presenças.

Fluxo 5: encontrar eventos por interesse

O usuário abre o mapa.

Aplica filtro de esporte.

Escolhe uma data.

Define uma distância.

O app mostra somente eventos compatíveis.

O usuário escolhe um evento e confirma presença.

24. Estrutura conceitual dos dados

Mesmo sem entrar em tecnologia, é bom pensar nas principais entidades do app.

Usuário:

Nome.

Foto.

Bio.

Esportes de interesse.

Nível.

Cidade.

Eventos criados.

Eventos confirmados.

Evento:

Título.

Descrição.

Categoria.

Localização.

Endereço ou referência.

Data.

Horário de início.

Horário de término.

Criador.

Participantes.

Limite de participantes.

Status.

Visibilidade.

Data de criação.

Participação:

Usuário.

Evento.

Status da presença.

Data de confirmação.

Grupo:

Nome.

Descrição.

Foto.

Criador.

Administradores.

Membros.

Eventos do grupo.

Comentário:

Evento.

Autor.

Texto.

Data.

Denúncia:

Tipo: evento, usuário ou comentário.

Autor da denúncia.

Motivo.

Descrição.

Status da análise.

25. Prioridade de desenvolvimento

Uma boa ordem de desenvolvimento seria:

Primeiro, implementar o cadastro, login e perfil simples.

Depois, implementar criação de evento.

Depois, implementar exibição dos eventos no mapa.

Depois, implementar detalhes do evento.

Depois, implementar confirmação e cancelamento de presença.

Depois, implementar tela de meus eventos.

Depois, implementar filtros básicos.

Depois, implementar cancelamento e edição de eventos.

Depois, implementar notificações.

Depois, implementar denúncias e bloqueios.

Depois, implementar comentários.

Depois, implementar grupos.

Essa ordem é boa porque começa pelo coração do app: criar, visualizar e participar de eventos.

26. Critérios de sucesso do MVP

Para saber se a primeira versão está funcionando, acompanhe alguns indicadores.

Quantidade de eventos criados.

Quantidade de usuários que confirmam presença.

Quantidade média de participantes por evento.

Percentual de eventos com pelo menos 2 pessoas confirmadas.

Quantidade de usuários que voltam ao app depois do primeiro uso.

Esportes mais usados.

Regiões com mais eventos.

Eventos cancelados.

Denúncias recebidas.

O indicador mais importante no começo é:

“Quantos eventos criados realmente conseguem atrair pelo menos mais uma pessoa?”

Porque esse é o valor principal do app.

27. Cuidados importantes

O app não deve depender somente de muitos usuários para ser útil. No início, pode haver poucos eventos. Então é importante incentivar criação de eventos e talvez permitir compartilhamento externo.

Um usuário que cria uma corrida precisa conseguir mandar o evento para amigos por WhatsApp, Instagram ou link. Assim, mesmo com pouca gente no app, ele consegue trazer participantes.

Outro cuidado: eventos passados não devem poluir o mapa. O mapa precisa parecer vivo, com eventos atuais e futuros.

Também é importante não complicar a criação de evento. O ideal é que o usuário consiga criar um evento em menos de um minuto.

28. Funcionalidades que eu deixaria para depois

Algumas ideias são boas, mas não precisam entrar no início:

Pagamento dentro do app.

Assinatura premium.

Ranking competitivo.

Chat privado.

Avaliação individual de usuários.

Sistema avançado de amizade.

Gamificação complexa.

Eventos pagos.

Verificação oficial de organizadores.

Recomendação automática avançada.

Essas coisas podem ser úteis no futuro, mas no começo podem atrasar a validação da ideia principal.

29. Roadmap resumido

Versão 1 — MVP:

Usuários, mapa, criação de eventos, confirmação de presença, detalhes do evento, meus eventos e filtros básicos.

Versão 2 — Engajamento:

Comentários, notificações melhores, compartilhamento, eventos recorrentes, lista de espera e denúncias.

Versão 3 — Comunidade:

Grupos, eventos privados, membros, administradores, convites e eventos exclusivos.

Versão 4 — Confiança e crescimento:

Reputação, verificação, recomendações personalizadas, estatísticas e possíveis recursos premium.

30. Resumo final

O app deve ser desenvolvido em torno de três ações principais:

Criar um evento em um lugar e horário.

Descobrir eventos próximos no mapa.

Confirmar presença para encontrar outras pessoas.

Todo o resto deve apoiar essas três ações.

Para a primeira versão, o mais importante é entregar uma experiência simples: o usuário cria uma corrida, futebol, pedal ou treino; outras pessoas veem no mapa; confirmam presença; e todos sabem onde e quando se encontrar.