import 'package:bonfire/bonfire.dart';
import 'package:bonfire_bloc/bonfire_bloc.dart';
import 'package:bonfire_multiplayer/components/my_player/my_player.dart';
import 'package:bonfire_multiplayer/components/my_remote_player/bloc/my_remote_player_bloc.dart';
import 'package:bonfire_multiplayer/data/my_websocket.dart';
import 'package:bonfire_multiplayer/spritesheets/players_spritesheet.dart';

class MyRemotePlayer extends SimplePlayer
    with
        BlockMovementCollision,
        BonfireBlocListenable<MyRemotePlayerBloc, MyRemotePlayerState> {
  MyRemotePlayer({
    required super.position,
    required PayerSkin skin,
    required MyWebsocket websocket,
    required String id,
  }) : super(
          size: Vector2.all(32),
          animation: PlayersSpriteSheet.simpleAnimation(skin.path),
          initDirection: Direction.down,
        ) {
    bloc = MyRemotePlayerBloc(id, position, websocket);
  }

  @override
  Future<void> onLoad() {
    // adds Rectangle collision
    add(
      RectangleHitbox(
        size: size / 2,
        position: Vector2(size.x / 4, size.y / 2),
      ),
    );
    return super.onLoad();
  }

  @override
  bool onBlockMovement(Set<Vector2> intersectionPoints, GameComponent other) {
    // cancel collision with Myplayer
    if (other is MyPlayer) {
      return false;
    }
    return super.onBlockMovement(intersectionPoints, other);
  }

  @override
  void onNewState(MyRemotePlayerState state) {
    // if distance greater than 5 pixel do interpolation of position
    if (position.distanceTo(state.position) > 5) {
      add(
        MoveEffect.to(
          state.position,
          EffectController(
            duration: 0.3,
          ),
        ),
      );
    }
    if (state.direction != null) {
      moveFromDirection(state.direction!);
    } else {
      stopMove(forceIdle: true);
    }
    super.onNewState(state);
  }
}
