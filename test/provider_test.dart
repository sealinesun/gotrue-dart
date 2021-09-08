import 'package:gotrue/gotrue.dart';
import 'package:test/test.dart';

void main() {
  const gotrueUrl = 'http://localhost:9999';
  const annonToken = '';

  late GoTrueClient client;
  late Session session;

  setUpAll(() async {
    client = GoTrueClient(
      url: gotrueUrl,
      headers: {
        'Authorization': 'Bearer $annonToken',
        'apikey': annonToken,
      },
    );
    final timestamp = (DateTime.now().millisecondsSinceEpoch / 1000).round();
    final email = 'fake2$timestamp@email.com';
    const password = 'secret';
    final res = await client.signUp(email, password);
    session = res.data!;
  });

  test('signIn() with Provider', () async {
    final res = await client.signIn(provider: Provider.google);
    final error = res.error;
    final url = res.url;
    final provider = res.provider;
    expect(error, isNull);
    expect(url, '$gotrueUrl/authorize?provider=google');
    expect(provider, 'google');
  });

  test('signIn() with Provider and options', () async {
    final res = await client.signIn(
      provider: Provider.github,
      options: AuthOptions(
        redirectTo: 'redirectToURL',
        scopes: 'repo',
      ),
    );
    final error = res.error;
    final url = res.url;
    final provider = res.provider;
    expect(error, isNull);
    expect(
      url,
      '$gotrueUrl/authorize?provider=github&scopes=repo&redirect_to=redirectToURL',
    );
    expect(provider, 'github');
  });

  test('parse provider callback url with fragment', () async {
    final accessToken = session.accessToken;
    const expiresIn = 12345;
    const refreshToken = 'my_refresh_token';
    const tokenType = 'my_token_type';
    const providerToken = 'my_provider_token_with_fragment';
    final url =
        'http://my-callback-url.com/welcome#access_token=$accessToken&expires_in=$expiresIn&refresh_token=$refreshToken&token_type=$tokenType&provider_token=$providerToken';
    final res = await client.getSessionFromUrl(Uri.parse(url));
    expect(res.data?.accessToken, accessToken);
    expect(res.data?.expiresIn, expiresIn);
    expect(res.data?.refreshToken, refreshToken);
    expect(res.data?.tokenType, tokenType);
    expect(res.data?.providerToken, providerToken);
  });

  test('parse provider callback url with fragment and query', () async {
    final accessToken = session.accessToken;
    const expiresIn = 12345;
    const refreshToken = 'my_refresh_token';
    const tokenType = 'my_token_type';
    const providerToken = 'my_provider_token_fragment_and_query';
    final url =
        'http://my-callback-url.com?page=welcome&foo=bar#access_token=$accessToken&expires_in=$expiresIn&refresh_token=$refreshToken&token_type=$tokenType&provider_token=$providerToken';
    final res = await client.getSessionFromUrl(Uri.parse(url));
    expect(res.data?.accessToken, accessToken);
    expect(res.data?.expiresIn, expiresIn);
    expect(res.data?.refreshToken, refreshToken);
    expect(res.data?.tokenType, tokenType);
    expect(res.data?.providerToken, providerToken);
  });

  test('parse provider callback url with missing param error', () async {
    final accessToken = session.accessToken;
    final url =
        'http://my-callback-url.com?page=welcome&foo=bar#access_token=$accessToken';
    final res = await client.getSessionFromUrl(Uri.parse(url));
    expect(res.error, isNotNull);
    expect(res.error?.message, 'No expires_in detected.');
  });

  test('parse provider callback url with error', () async {
    const errorDesc = 'my_error_description';
    const url =
        'http://my-callback-url.com?page=welcome&foo=bar#error_description=$errorDesc';
    final res = await client.getSessionFromUrl(Uri.parse(url));
    expect(res.error?.message, errorDesc);
  });
}
