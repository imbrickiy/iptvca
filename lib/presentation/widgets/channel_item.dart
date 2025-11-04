
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:iptvca/core/utils/debounce.dart';
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
  late final Debounce _debounce;
  bool? _localIsFavorite;

  @override
  void initState() {
    super.initState();
    _debounce = Debounce(const Duration(milliseconds: 300));
  }

  @override
  void dispose() {
    _debounce.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: BlocBuilder<ChannelBloc, ChannelState>(
        buildWhen: (previous, current) {
          if (previous is ChannelsLoaded && current is ChannelsLoaded) {
            final prevChannelIndex = previous.channels.indexWhere((c) => c.id == widget.channel.id);
            final currChannelIndex = current.channels.indexWhere((c) => c.id == widget.channel.id);
            if (prevChannelIndex == -1 && currChannelIndex == -1) {
              return false;
            }
            if (prevChannelIndex != -1 && currChannelIndex != -1) {
              final prevChannel = previous.channels[prevChannelIndex];
              final currChannel = current.channels[currChannelIndex];
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
            final channelIndex = state.channels.indexWhere((c) => c.id == widget.channel.id);
            if (channelIndex != -1) {
              currentChannel = state.channels[channelIndex];
              isFavorite = currentChannel.isFavorite;
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
              onPressed: () => _debounce(() {
                final newFavoriteStatus = !isFavorite;
                setState(() {
                  _localIsFavorite = newFavoriteStatus;
                });
                context.read<ChannelBloc>().add(
                      ToggleFavoriteEvent(currentChannel),
                    );
              }),
            ),
            onTap: () => _debounce(() {
              context.read<ChannelBloc>().add(
                    SelectChannelEvent(currentChannel),
                  );
              context.push('/player', extra: currentChannel);
            }),
          );
        },
      ),
    );
  }
}

