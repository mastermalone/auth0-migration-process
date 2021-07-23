const server = require('server');
const { get, post } = server.router;
const textInsert = require('./scripts/update-json');

//Launch the server with a couple of routes
server({ port: 8200 }, [
  get('/', (ctx) => {
    console.log('Yo Scooby');
    textInsert.updateJson();
    return 'ok';
  }),
  post('/scoobySnacks', (ctx) => {
    console.log(ctx.data);
    return 'ok';
  }),
]);
