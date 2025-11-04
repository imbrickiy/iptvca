
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:iptvca/domain/entities/channel.dart';
import 'package:iptvca/presentation/bloc/channel/channel_bloc.dart';
import 'package:iptvca/presentation/bloc/channel/channel_event.dart';
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
    final channel = widget.channel;
    final isFavorite = _localIsFavorite ?? channel.isFavorite;
    return RepaintBoundary(
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: ListTile(
          leading: channel.logoUrl != null
              ? CachedNetworkImage(
                  imageUrl: channel.logoUrl!,
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
          title: Text(channel.name),
          subtitle: channel.groupTitle != null
              ? Text(channel.groupTitle!)
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
                    ToggleFavoriteEvent(channel),
                  );
            },
          ),
          onTap: () {
            context.read<ChannelBloc>().add(
                  SelectChannelEvent(channel),
                );
            context.push('/player', extra: channel);
          },
        ),
      ),
    );
  }
}

