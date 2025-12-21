import 'package:flutter/material.dart';

class SongListScreen extends StatelessWidget {
  final bool isReadOnly;

  const SongListScreen({super.key, this.isReadOnly = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choir Songs'),
        actions: [
          // 1. Hide the Search or Filter if you want, but keep it for guests
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
        ],
      ),
      // 2. Hide the Floating Action Button for Guests
      // floatingActionButton: isReadOnly
      //     ? null
      //     : FloatingActionButton(
      //         onPressed: () => _navigateToAddSong(context),
      //         child: const Icon(Icons.add),
      //       ),
      // body: BlocBuilder<SongCubit, SongState>(
      //   builder: (context, state) {
      //     if (state is SongLoading) return const Center(child: CircularProgressIndicator());

      //     if (state is SongLoaded) {
      //       return ListView.builder(
      //         itemCount: state.songs.length,
      //         itemBuilder: (context, index) {
      //           final song = state.songs[index];
      //           return ListTile(
      //             title: Text(song.title),
      //             subtitle: Text(song.category),
      //             // 3. Hide the Edit/Delete trailing icons for Guests
      //             trailing: isReadOnly
      //                 ? const Icon(Icons.chevron_right) // Just an arrow for guests
      //                 : IconButton(
      //                     icon: const Icon(Icons.edit),
      //                     onPressed: () => _navigateToEdit(context, song),
      //                   ),
      //             onTap: () => _viewSongDetails(context, song),
      //           );
      //         },
      //       );
      // }
      // return const Center(child: Text("No songs found."));
      // },
      // ),
    );
  }
}
