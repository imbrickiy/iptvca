
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:iptvca/domain/entities/channel.dart';
import 'package:iptvca/presentation/bloc/channel/channel_bloc.dart';
import 'package:iptvca/presentation/bloc/channel/channel_event.dart';
import 'package:iptvca/presentation/bloc/channel/channel_state.dart';
import 'package:go_router/go_router.dart';

class ChannelItem extends StatefulWidget {
  const ChannelItem({super.key, required this.channel});
  final Channel channel;

  @override
  State<ChannelItem> createState() => _ChannelItemState();
}

class _ChannelItemState extends State<ChannelItem> {
  bool? _localIsFavorite;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: BlocBuilder<ChannelBloc, ChannelState>(
        buildWhen: (previous, current) {
          if (previous is ChannelsLoaded && current is ChannelsLoaded) {
            final prevChannel = previous.channelsMap[widget.channel.id];
            final currChannel = current.channelsMap[widget.channel.id];
            if (prevChannel == null && currChannel == null) {
              return false;
            }
            if (prevChannel != null && currChannel != null) {
              if (prevChannel.isFavorite != currChannel.isFavorite) {
                _localIsFavorite = null;
                return true;
              }
            }
          }
          return previous != current;
        },
        builder: (context, state) {
          Channel currentChannel = widget.channel;
          bool isFavorite = widget.channel.isFavorite;
          if (state is ChannelsLoaded) {
            final channel = state.channelsMap[widget.channel.id];
            if (channel != null) {
              currentChannel = channel;
              isFavorite = channel.isFavorite;
            }
          }
          if (_localIsFavorite != null) {
            isFavorite = _localIsFavorite!;
          }
          return ListTile(
            leading: currentChannel.logoUrl != null
                ? CachedNetworkImage(
                    imageUrl: currentChannel.logoUrl!,
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                    memCacheWidth: 128,
                    memCacheHeight: 128,
                    placeholder: (context, url) => const SizedBox(
                      width: 64,
                      height: 64,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => const Icon(Icons.tv),
                  )
                : const Icon(Icons.tv, size: 64),
            title: Text(currentChannel.name),
            subtitle: currentChannel.groupTitle != null
                ? Text(currentChannel.groupTitle!)
                : null,
            trailing: IconButton(
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? Colors.red : null,
              ),
              onPressed: () {
                final newFavoriteStatus = !isFavorite;
                setState(() {
                  _localIsFavorite = newFavoriteStatus;
                });
                context.read<ChannelBloc>().add(
                      ToggleFavoriteEvent(currentChannel),
                    );
              },
            ),
            onTap: () {
              context.read<ChannelBloc>().add(
                    SelectChannelEvent(currentChannel),
                  );
              context.push('/player', extra: currentChannel);
            },
          );
        },
      ),
      ),
    );
  }
}

